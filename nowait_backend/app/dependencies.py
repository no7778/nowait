import httpx
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import ExpiredSignatureError, JWTError, jwt

from app.config import settings
from app.database import execute_one, supabase

security = HTTPBearer()

_jwks_cache: list | None = None


def _get_jwks() -> list:
    """Fetch and cache Supabase JWKS (public keys for ES256 token verification)."""
    global _jwks_cache
    if _jwks_cache is None:
        resp = httpx.get(
            f"{settings.SUPABASE_URL}/auth/v1/.well-known/jwks.json", timeout=5.0
        )
        resp.raise_for_status()
        _jwks_cache = resp.json().get("keys", [])
    return _jwks_cache


def decode_jwt(token: str) -> dict:
    # Try HS256 first (legacy Supabase projects)
    try:
        return jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            audience="authenticated",
        )
    except ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
    except JWTError:
        pass

    # Fall back to ES256/RS256 via JWKS (newer Supabase projects)
    try:
        header = jwt.get_unverified_header(token)
        kid = header.get("kid")
        alg = header.get("alg", "ES256")
        keys = _get_jwks()
        key = next((k for k in keys if k.get("kid") == kid), keys[0] if keys else None)
        if key:
            return jwt.decode(token, key, algorithms=[alg], audience="authenticated")
    except ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
    except Exception:
        pass

    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    payload = decode_jwt(credentials.credentials)
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")

    result = execute_one(supabase.table("profiles").select("*").eq("id", user_id))
    if not result.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found. Please complete registration.",
        )
    return result.data


def get_current_owner(current_user: dict = Depends(get_current_user)) -> dict:
    if current_user.get("role") != "owner":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Owner access required")
    return current_user


def get_token_user_id(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    """Returns user ID from token without requiring a profile (used for profile creation)."""
    payload = decode_jwt(credentials.credentials)
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    return user_id


def get_token_claims(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Returns full JWT payload including phone claim. Used for profile creation."""
    return decode_jwt(credentials.credentials)
