from pydantic import BaseModel
from typing import Optional


class AddStaffRequest(BaseModel):
    phone: str  # Find user by phone number


class StaffMemberResponse(BaseModel):
    id: str
    shop_id: str
    user_id: str
    display_name: str
    is_owner_staff: bool
    is_active: bool
    avg_service_minutes: Optional[float]
    created_at: str


