from datetime import datetime, timedelta, timezone

from fastapi import HTTPException

from app.database import execute_one, supabase
from app.schemas.subscription import SubscriptionCreate

PLAN_PRICES = {"basic": 499, "premium": 999}


def get_subscription(shop_id: str, owner_id: str) -> dict:
    shop = execute_one(
        supabase.table("shops")
        .select("id")
        .eq("id", shop_id)
        .eq("owner_id", owner_id)
    )
    if not shop.data:
        raise HTTPException(status_code=403, detail="Not authorized or shop not found")

    result = execute_one(supabase.table("subscriptions").select("*").eq("shop_id", shop_id))
    if not result.data:
        return {"has_active_subscription": False, "subscription": None}

    sub = result.data
    now = datetime.now(timezone.utc)
    expires_at = datetime.fromisoformat(sub["expires_at"].replace("Z", "+00:00"))
    days_remaining = max(0, (expires_at - now).days)

    is_active = sub["status"] == "active" and expires_at > now
    sub_response = {**sub, "days_remaining": days_remaining}

    return {"has_active_subscription": is_active, "subscription": sub_response}


def create_or_renew_subscription(shop_id: str, owner_id: str, data: SubscriptionCreate) -> dict:
    shop = execute_one(
        supabase.table("shops")
        .select("id")
        .eq("id", shop_id)
        .eq("owner_id", owner_id)
    )
    if not shop.data:
        raise HTTPException(status_code=403, detail="Not authorized or shop not found")

    if data.plan not in PLAN_PRICES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid plan. Choose from: {list(PLAN_PRICES.keys())}",
        )
    if data.duration_days not in (30, 90, 365):
        raise HTTPException(status_code=400, detail="Duration must be 30, 90, or 365 days")

    now = datetime.now(timezone.utc)
    expires_at = now + timedelta(days=data.duration_days)

    existing = execute_one(
        supabase.table("subscriptions")
        .select("id")
        .eq("shop_id", shop_id)
    )
    sub_data = {
        "shop_id": shop_id,
        "plan": data.plan,
        "status": "active",
        "started_at": now.isoformat(),
        "expires_at": expires_at.isoformat(),
    }

    if existing.data:
        result = supabase.table("subscriptions").update(sub_data).eq("shop_id", shop_id).execute()
    else:
        result = supabase.table("subscriptions").insert(sub_data).execute()

    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to create/renew subscription")

    sub = result.data[0]
    days_remaining = data.duration_days
    return {"has_active_subscription": True, "subscription": {**sub, "days_remaining": days_remaining}}


def cancel_subscription(shop_id: str, owner_id: str) -> dict:
    shop = execute_one(
        supabase.table("shops")
        .select("id")
        .eq("id", shop_id)
        .eq("owner_id", owner_id)
    )
    if not shop.data:
        raise HTTPException(status_code=403, detail="Not authorized or shop not found")

    result = (
        supabase.table("subscriptions")
        .update({"status": "cancelled"})
        .eq("shop_id", shop_id)
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=404, detail="No subscription found to cancel")
    return {"has_active_subscription": False, "subscription": result.data[0]}
