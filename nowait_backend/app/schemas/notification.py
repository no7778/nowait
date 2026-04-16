from typing import List, Optional
from pydantic import BaseModel


class NotificationResponse(BaseModel):
    id: str
    type: str
    title: str
    body: str
    shop_name: str
    shop_id: Optional[str]
    is_read: bool
    created_at: str


class NotificationsListResponse(BaseModel):
    notifications: List[NotificationResponse]
    unread_count: int


class MarkReadResponse(BaseModel):
    message: str
    updated_count: int
