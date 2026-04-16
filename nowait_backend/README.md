# NOWAIT Backend API

FastAPI + Supabase backend for the NOWAIT queue management app.

---

## Setup

### 1. Configure Environment

```bash
cp .env.example .env
```

Fill in your Supabase project values in `.env`:

| Variable | Where to find it |
|---|---|
| `SUPABASE_URL` | Project Settings > API > Project URL |
| `SUPABASE_SERVICE_KEY` | Project Settings > API > service_role (secret) |
| `SUPABASE_ANON_KEY` | Project Settings > API > anon (public) |
| `SUPABASE_JWT_SECRET` | Project Settings > API > JWT Settings > JWT Secret |

### 2. Run the SQL Schema

1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Paste the contents of `sql/schema.sql` and run it

This creates all tables, indexes, RLS policies, and stored functions.

### 3. Enable Phone Auth (Supabase)

1. Go to **Authentication > Providers**
2. Enable **Phone** provider
3. Add your Twilio credentials:
   - Account SID
   - Auth Token
   - Message Service SID (or From number)
4. Set **OTP expiry** (recommended: 300 seconds)

---

## Running the Server

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`.

**Interactive API docs:** http://localhost:8000/docs

**ReDoc:** http://localhost:8000/redoc

---

## Docker

```bash
docker build -t nowait-backend .
docker run -p 8000:8000 --env-file .env nowait-backend
```

---

## API Endpoints

### Health
| Method | Path | Description |
|---|---|---|
| GET | `/` | Service status |
| GET | `/health` | Health check |

### Authentication
| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/send-otp` | No | Send OTP to phone (E.164 format) |
| POST | `/auth/verify-otp` | No | Verify OTP, receive JWT tokens |
| POST | `/auth/complete-profile` | Bearer | Set name, city, role (first login only) |
| GET | `/auth/me` | Bearer | Get current user profile |
| POST | `/auth/refresh` | No | Refresh access token |

### Shops
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/shops` | No | List shops (filter: city, category, open_only) |
| GET | `/shops/categories` | No | List all categories |
| GET | `/shops/my` | Owner | Get owner's own shop |
| GET | `/shops/{shop_id}` | No | Get shop detail with services and promotions |
| POST | `/shops` | Owner | Create a shop (one per owner) |
| PUT | `/shops/{shop_id}` | Owner | Update shop details |
| POST | `/shops/{shop_id}/toggle-open` | Owner | Toggle shop open/closed |
| POST | `/shops/{shop_id}/services` | Owner | Add a service |
| DELETE | `/shops/services/{service_id}` | Owner | Delete a service |

### Queue
| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/queues/join` | Customer | Join a shop's queue |
| GET | `/queues/status` | Customer | Get active queue entries (all or by shop) |
| DELETE | `/queues/{entry_id}/cancel` | Customer | Cancel a waiting entry |
| GET | `/queues/shop/{shop_id}` | Owner | View full shop queue with customer details |
| POST | `/queues/shop/{shop_id}/next` | Owner | Advance queue (complete current, serve next) |
| POST | `/queues/{entry_id}/skip` | Owner | Skip a customer |

### Notifications
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/notifications` | Customer | Get last 50 notifications with unread count |
| PATCH | `/notifications/{id}/read` | Customer | Mark single notification as read |
| PATCH | `/notifications/read-all` | Customer | Mark all notifications as read |

### Promotions
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/promotions/shop/{shop_id}` | No | Get shop promotions (active_only query param) |
| POST | `/promotions/shop/{shop_id}` | Owner | Create a promotion |
| PUT | `/promotions/{promotion_id}` | Owner | Update promotion |
| DELETE | `/promotions/{promotion_id}` | Owner | Delete promotion |

### Subscriptions
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/subscriptions/shop/{shop_id}` | Owner | Get subscription status |
| POST | `/subscriptions/shop/{shop_id}` | Owner | Create or renew subscription |
| DELETE | `/subscriptions/shop/{shop_id}` | Owner | Cancel subscription |

---

## Queue Flow Explained

### FIFO Token System

- Every customer who joins gets a monotonically increasing **token number** (e.g., 1, 2, 3...)
- Token numbers never reset within a shop — they keep incrementing
- The owner calls `POST /queues/shop/{id}/next` to advance: marks the current `serving` entry as `completed` and promotes the next `waiting` entry to `serving`

### Customer `display_status` Values

| Value | Meaning |
|---|---|
| `waiting` | In queue, position 4 or later |
| `almostThere` | In queue, position 1-3 |
| `yourTurn` | Currently being served (status = `serving`) |
| `completed` | Service completed |
| `skipped` | Skipped by owner |
| `cancelled` | Cancelled by customer |

### Estimated Wait

`estimated_wait_minutes = (position - 1) * avg_wait_minutes`

The `avg_wait_minutes` is set by the shop owner and represents average time per customer.

### Atomic Queue Join

The `join_queue` PostgreSQL function runs atomically to:
1. Lock the shop row (prevents race conditions)
2. Verify the shop is open
3. Verify an active subscription exists
4. Check the user isn't already in the queue
5. Assign the next token number
6. Insert the queue entry

### Notifications

Notifications are created server-side when:
- `your_turn` — sent to the customer being called to serve
- `almost_there` — sent to customers at positions 2 and 3 after each advance
- `skipped` — sent to a customer who was skipped by the owner
- `promotion` — can be sent manually (future feature)

---

## Role-Based Access

- **customer** — can join queues, track status, view notifications, cancel own entry
- **owner** — can manage shop, view/advance queue, manage subscriptions and promotions

Role is set once during `POST /auth/complete-profile` and cannot be changed via the API.

---

## Supabase RLS Summary

Row Level Security is enabled on all tables. The service role key (used by this backend) bypasses RLS for server-side operations. The anon key is used only for OTP flows.

Key policies:
- `profiles` — readable by all, writable only by the owner of that profile
- `shops` — readable by all, writable only by the shop owner
- `queue_entries` — visible to the customer (own entries) and the shop owner
- `notifications` — visible only to the recipient user
- `subscriptions` — visible only to the shop owner
