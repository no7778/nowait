from typing import Optional
from pydantic import BaseModel


class JoinQueueRequest(BaseModel):
    shop_id: str
    service_id: Optional[str] = None


class QueueEntryResponse(BaseModel):
    id: str
    shop_id: str
    shop_name: str
    user_id: str
    token_number: int
    status: str
    display_status: str
    position: int
    people_ahead: int
    estimated_wait_minutes: int
    now_serving_token: Optional[int]
    joined_at: str


class QueueListItem(BaseModel):
    id: str
    user_id: str
    customer_name: str
    customer_phone: str
    token_number: int
    status: str
    position: int
    service_id: Optional[str]
    coming_at: Optional[str]
    joined_at: str


class ShopQueueResponse(BaseModel):
    shop_id: str
    shop_name: str
    is_open: bool
    queue_paused: bool
    max_queue_size: Optional[int]
    total_waiting: int
    now_serving_token: Optional[int]
    queue: list[QueueListItem]


class AdvanceQueueResponse(BaseModel):
    message: str
    completed_token: Optional[int]
    now_serving_token: Optional[int]
    total_remaining: int


class CancelQueueResponse(BaseModel):
    message: str
    entry_id: str
