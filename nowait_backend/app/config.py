from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_SERVICE_KEY: str
    SUPABASE_ANON_KEY: str
    SUPABASE_JWT_SECRET: str
    DEMO_MODE: bool = True          # Set False in production
    DEMO_OTP: str = "123456"
    DEMO_PASSWORD: str = "NowaitDemo#2024"

    class Config:
        env_file = ".env"


settings = Settings()
