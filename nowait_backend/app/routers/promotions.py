from fastapi import APIRouter, Depends, Query

from app.dependencies import get_current_owner
from app.schemas.promotion import PromotionCreate, PromotionListResponse, PromotionResponse, PromotionUpdate
from app.services import promotion_service

router = APIRouter(prefix="/promotions", tags=["Promotions"])


@router.get("/shop/{shop_id}", response_model=PromotionListResponse, summary="Get shop promotions")
def get_shop_promotions(
    shop_id: str,
    active_only: bool = Query(False, description="Return only active (non-expired) promotions"),
):
    """Returns all promotions for a shop. Use active_only=true to filter expired ones."""
    return promotion_service.get_shop_promotions(shop_id, active_only)


@router.post("/shop/{shop_id}", response_model=PromotionResponse, status_code=201, summary="Create a promotion (owner only)")
def create_promotion(shop_id: str, body: PromotionCreate, current_user: dict = Depends(get_current_owner)):
    """
    Create a new promotion for the shop.

    **Sample Request:**
    ```json
    {
      "title": "Summer Special",
      "description": "20% off all services this summer",
      "valid_until": "2025-08-31T23:59:59Z"
    }
    ```
    """
    return promotion_service.create_promotion(shop_id, current_user["id"], body)


@router.put("/{promotion_id}", response_model=PromotionResponse, summary="Update a promotion (owner only)")
def update_promotion(promotion_id: str, body: PromotionUpdate, current_user: dict = Depends(get_current_owner)):
    """Update title, description, valid_until, or is_active status."""
    return promotion_service.update_promotion(promotion_id, current_user["id"], body)


@router.delete("/{promotion_id}", status_code=204, summary="Delete a promotion (owner only)")
def delete_promotion(promotion_id: str, current_user: dict = Depends(get_current_owner)):
    """Permanently delete a promotion."""
    promotion_service.delete_promotion(promotion_id, current_user["id"])
