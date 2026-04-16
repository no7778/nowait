from typing import List, Optional
from pydantic import BaseModel


class PromotionCreate(BaseModel):
    title: str
    description: str
    valid_until: str  # ISO datetime string


class PromotionUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    valid_until: Optional[str] = None
    is_active: Optional[bool] = None


class PromotionResponse(BaseModel):
    id: str
    shop_id: str
    title: str
    description: str
    valid_until: str
    is_active: bool
    created_at: str


class PromotionListResponse(BaseModel):
    promotions: List[PromotionResponse]
