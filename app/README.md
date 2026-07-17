# Items App (React + Express + Postgres RDS)

Simplest possible full-stack CRUD app: add/list/delete "items".

## Structure
```
backend/    Express API, connects to your RDS Postgres instance
frontend/   React app, calls the backend API
docker-compose.yml   for local testing (optional, since you have your own infra)
```

## Backend env vars (set these wherever you deploy, e.g. ECS task def, EC2 env, etc.)
```
DB_HOST=your-rds-endpoint.rds.amazonaws.com
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your-password
DB_NAME=postgres
DB_SSL=true
PORT=4000
```
The backend auto-creates the `items` table on startup — no manual migration needed.

## Frontend env var (set at BUILD time, since it's a static React app)
```
REACT_APP_API_URL=http://your-backend-host:4000
```

## Run locally with Docker
1. Copy `backend/.env.example` to `.env` in the repo root and fill in your real RDS credentials (docker-compose reads from `.env` automatically).
2. Make sure your RDS security group allows inbound connections from wherever you're running this (your IP / your infra's network).
3.
```bash
docker compose up --build
```
- Frontend: http://localhost:3000
- Backend: http://localhost:4000/api/health

## Deploy on your own infra
Each service has its own Dockerfile, so you can build/push/run them independently:

```bash
# Backend
docker build -t items-backend ./backend
docker run -p 4000:4000 --env-file backend/.env items-backend

# Frontend (API URL must be baked in at build time)
docker build --build-arg REACT_APP_API_URL=http://your-backend-host:4000 -t items-frontend ./frontend
docker run -p 80:80 items-frontend
```

## API
| Method | Path              | Description       |
|--------|-------------------|--------------------|
| GET    | /api/health       | health check       |
| GET    | /api/items        | list all items     |
| POST   | /api/items        | create item `{name}` |
| DELETE | /api/items/:id    | delete item        |

## Notes
- RDS usually requires SSL — the backend defaults to SSL on (`rejectUnauthorized: false` for simplicity with RDS's default cert). Set `DB_SSL=false` only if your RDS instance has SSL disabled.
- Make sure your RDS security group / VPC allows traffic from wherever the backend container runs.
