from typing import List, Optional
from pydantic import BaseModel


class ServiceCreate(BaseModel):
    name: str
    description: str = ""
    price: float


class ServiceResponse(BaseModel):
    id: str
    shop_id: str
    name: str
    description: str
    price: float


class ShopCreate(BaseModel):
    name: str
    category: str
    address: str
    city: str
    avg_wait_minutes: int = 10
    images: List[str] = []
    description: str = ""
    services: List[ServiceCreate] = []


class ShopUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    avg_wait_minutes: Optional[int] = None
    images: Optional[List[str]] = None
    description: Optional[str] = None


class PromotionInShop(BaseModel):
    id: str
    title: str
    description: str
    valid_until: str
    is_active: bool


class ShopSummary(BaseModel):
    id: str
    name: str
    category: str
    address: str
    city: str
    is_open: bool
    has_active_subscription: bool
    can_accept_queue: bool
    avg_wait_minutes: int
    rating: float
    images: List[str]
    queue_count: int
    now_serving_token: Optional[int]
    description: str
    is_promoted: bool = False
    active_promotions: List[PromotionInShop] = []


class ShopDetail(ShopSummary):
    owner_id: str
    services: List[ServiceResponse]


class ShopListResponse(BaseModel):
    shops: List[ShopSummary]
    total: int


class ToggleOpenResponse(BaseModel):
    shop_id: str
    is_open: bool
    message: str
