"""Tests for notification_service.py — create, get, mark read."""
from unittest.mock import MagicMock, patch
import pytest

from tests.conftest import make_chain, ok, ok_list


class TestCreateNotification:
    def test_inserts_notification_row(self):
        from app.services import notification_service

        inserted = []
        chain = make_chain(ok_list([{"id": "notif-001"}]))
        chain.insert.side_effect = lambda data: inserted.append(data) or chain

        with patch("app.services.notification_service.supabase") as mock_sup:
            mock_sup.table = chain.table
            notification_service.create_notification(
                user_id="user-001",
                type="your_turn",
                title="Your Turn!",
                body="Token #5 please proceed",
                shop_name="Raj Salon",
                shop_id="shop-001",
            )

        assert len(inserted) == 1
        d = inserted[0]
        assert d["user_id"] == "user-001"
        assert d["type"] == "your_turn"
        assert d["shop_id"] == "shop-001"

    def test_returns_empty_dict_when_no_data(self):
        from app.services import notification_service

        chain = make_chain(ok_list([]))

        with patch("app.services.notification_service.supabase") as mock_sup:
            mock_sup.table = chain.table
            result = notification_service.create_notification(
                user_id="u", type="t", title="T", body="B", shop_name="S"
            )

        assert result == {}


class TestGetNotifications:
    def test_counts_unread_correctly(self):
        from app.services import notification_service

        notifs = [
            {"id": "n1", "is_read": False},
            {"id": "n2", "is_read": True},
            {"id": "n3", "is_read": False},
        ]
        chain = make_chain(ok_list(notifs))

        with patch("app.services.notification_service.supabase") as mock_sup:
            mock_sup.table = chain.table
            result = notification_service.get_notifications("user-001")

        assert result["unread_count"] == 2
        assert len(result["notifications"]) == 3


class TestMarkRead:
    def test_raises_404_if_not_found(self):
        from app.services import notification_service
        from fastapi import HTTPException

        with patch("app.services.notification_service.execute_one", return_value=MagicMock(data=None)):
            with pytest.raises(HTTPException) as exc:
                notification_service.mark_read("notif-001", "user-001")
            assert exc.value.status_code == 404

    def test_marks_notification_read(self):
        from app.services import notification_service

        updates = []
        chain = make_chain(ok_list([]))
        chain.update.side_effect = lambda data: updates.append(data) or chain

        with patch("app.services.notification_service.execute_one", return_value=MagicMock(data={"id": "notif-001"})), \
             patch("app.services.notification_service.supabase") as mock_sup:
            mock_sup.table = chain.table
            result = notification_service.mark_read("notif-001", "user-001")

        assert result["updated_count"] == 1
        assert any(u.get("is_read") is True for u in updates)


class TestMarkAllRead:
    def test_marks_all_unread_as_read(self):
        from app.services import notification_service

        marked = [{"id": "n1"}, {"id": "n2"}]
        chain = make_chain(ok_list(marked))

        with patch("app.services.notification_service.supabase") as mock_sup:
            mock_sup.table = chain.table
            result = notification_service.mark_all_read("user-001")

        assert result["updated_count"] == 2
