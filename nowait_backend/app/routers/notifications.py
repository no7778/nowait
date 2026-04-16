from fastapi import APIRouter, Depends

from app.dependencies import get_current_user
from app.schemas.notification import MarkReadResponse, NotificationsListResponse
from app.services import notification_service

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("", response_model=NotificationsListResponse, summary="Get user notifications")
def get_notifications(current_user: dict = Depends(get_current_user)):
    """Returns last 50 notifications with unread count."""
    return notification_service.get_notifications(current_user["id"])


@router.patch("/{notification_id}/read", response_model=MarkReadResponse, summary="Mark notification as read")
def mark_read(notification_id: str, current_user: dict = Depends(get_current_user)):
    """Mark a single notification as read."""
    return notification_service.mark_read(notification_id, current_user["id"])


@router.patch("/read-all", response_model=MarkReadResponse, summary="Mark all notifications as read")
def mark_all_read(current_user: dict = Depends(get_current_user)):
    """Mark all unread notifications as read."""
    return notification_service.mark_all_read(current_user["id"])
