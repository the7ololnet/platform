# Email Marketing Platform

High inbox deliverability email marketing platform with distributed architecture.

## Architecture

### Current (Phase 0)
- **Backend**: FastAPI + SQLAlchemy 2 + Alembic + PostgreSQL
- **Frontend**: React + TypeScript + Vite
- **Cache/Queue**: Redis
- **Deployment**: Docker Compose on CentOS 9

### Future (Distributed)
- Control Plane
- Node Agents
- Redis Streams for messaging
- Safety Engine
- Real-time Dashboard

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Python 3.11+ (for local development)
- Node.js 20+ (for local development)

### Start All Services

```bash
# Copy environment variables
cp .env.example .env
# Edit .env with your values

# Build and start all services
docker compose build
docker compose up -d

# Check service status
docker compose ps

# View logs
docker compose logs -f
```

The application will be available at:
- Frontend: http://localhost
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/api/v1/docs

### Backend Development

```bash
cd backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest -v

# Run linters
black . --check
flake8 .
mypy .

# Format code
black .
isort .

# Run development server (standalone)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Development

```bash
cd frontend

# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Run linter
npm run lint

# Format code
npm run format
```

## Project Structure

```
.
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── v1/          # API v1 endpoints
│   │   ├── core/            # Configuration, database
│   │   ├── models/          # SQLAlchemy models
│   │   ├── schemas/         # Pydantic schemas
│   │   ├── services/        # Business logic
│   │   └── main.py          # FastAPI application
│   ├── tests/               # Backend tests
│   ├── requirements.txt     # Python dependencies
│   └── Dockerfile
│
├── frontend/
│   ├── src/
│   │   ├── App.tsx          # Main application component
│   │   ├── main.tsx         # Entry point
│   │   └── *.css            # Styles
│   ├── package.json         # Node dependencies
│   ├── vite.config.ts       # Vite configuration
│   └── Dockerfile
│
├── docker-compose.yml       # Service orchestration
├── .env                     # Environment variables (not in git)
├── .env.example             # Environment template
├── AGENTS.md                # AI Agent development guide
└── README.md
```

## Testing

### Backend Tests
```bash
cd backend
pytest -v --cov=app --cov-report=html
```

### Run Tests in Docker
```bash
docker compose exec backend pytest -v
```

## Environment Variables

See `.env.example` for all available configuration options.

Key variables:
- `POSTGRES_*`: Database configuration
- `REDIS_*`: Redis configuration
- `JWT_SECRET_KEY`: Authentication secret
- `ENVIRONMENT`: development/staging/production
- `DEBUG`: Enable debug mode

## Health Checks

- Backend: `http://localhost:8000/health`
- API v1: `http://localhost:8000/api/v1/health`

## Development Workflow

This project follows a phase-based development approach. See `AGENTS.md` for detailed guidelines.

### Current Phase: 0 - Project Setup ✅

**Completed:**
- [x] Project structure created
- [x] Backend FastAPI setup
- [x] Frontend React+TS+Vite setup
- [x] Docker Compose configuration
- [x] Testing frameworks configured
- [x] Linters and formatters configured
- [x] Health check endpoints
- [x] Basic CI/CD structure

### Next Phase: 1 - Core Backend API

Will include:
- Database models (campaigns, contacts, emails)
- CRUD API endpoints
- Authentication/Authorization
- Input validation
- Comprehensive tests

## Contributing

1. Follow the guidelines in `AGENTS.md`
2. Run tests before committing
3. Use linters and formatters
4. Write clear commit messages
5. Update documentation

## License

Proprietary - All rights reserved

## Support

For issues or questions, contact the development team.
