from typing import Optional
from pydantic import BaseModel


class SubscriptionCreate(BaseModel):
    plan: str  # 'basic' or 'premium'
    duration_days: int = 30  # 30, 90, 365


class SubscriptionResponse(BaseModel):
    id: str
    shop_id: str
    plan: str
    status: str
    started_at: str
    expires_at: str
    days_remaining: int
    created_at: str


class SubscriptionStatus(BaseModel):
    has_active_subscription: bool
    subscription: Optional[SubscriptionResponse] = None
