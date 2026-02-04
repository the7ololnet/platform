# AGENTS.md - AI Agent Development Guide

## Overview

This document provides strict guidelines for AI agents working on this project. All development must follow these rules to ensure quality, consistency, and proper verification.

---

## Project Structure

This is a full-stack platform with:
- **Backend**: Python-based API
- **Frontend**: Modern web application
- **Infrastructure**: Docker Compose orchestration

---

## STRICT EXECUTION RULES

### Rule 1: Phase-Based Development
- Implement ONLY the current phase scope
- NO feature creep or extras
- Complete one phase before moving to the next
- Wait for explicit "GO PHASE NEXT" command before proceeding

### Rule 2: Self-Verification (MANDATORY)
You MUST verify your implementation by running:

#### Backend Verification
```bash
# Run tests
pytest -v

# Run linters (if configured)
black . --check
flake8 .
mypy .
```

#### Frontend Verification
```bash
# Build the application
npm run build

# Run tests (if configured)
npm test

# Run linters (if configured)
npm run lint
```

#### Infrastructure Verification
```bash
# Build containers
docker compose build

# Start services
docker compose up -d

# Check service health
docker compose ps

# View logs
docker compose logs
```

### Rule 3: Secrets Management
If any secret/credential is needed:
1. Ask ONLY for `.env` values using a SHORT checklist
2. STOP and wait for the user to provide them
3. Never hardcode secrets
4. Never commit secrets to git

### Rule 4: Git Operations
- Create feature branch if it doesn't exist
- Commit frequently with clear messages
- Push changes as you go
- Multiple small commits > one large commit
- ALWAYS commit and push before testing

---

## Phase Completion Protocol

After finishing each phase, you MUST report:

```
PHASE [X] COMPLETE

## Commands Executed
[List all verification commands you ran]

## Output Summary
- Backend Tests: [PASS/FAIL - X passed, Y failed]
- Frontend Build: [PASS/FAIL]
- Docker Compose: [PASS/FAIL]
- Linters: [PASS/FAIL]

## Definition of Done
- [ ] All tests passing
- [ ] Build successful
- [ ] Docker containers running
- [ ] Code follows style guidelines
- [ ] Changes committed and pushed
- [ ] No secrets in code
- [ ] Documentation updated

## Next Phase Requirements
[List ONLY the inputs needed from user for next phase]
```

Then STOP and wait for "GO PHASE NEXT" command.

---

## Development Phases

### Phase 0: Project Setup
**Scope**: Initialize project structure and dependencies

**Tasks**:
- Set up backend structure (Python/FastAPI or Django)
- Set up frontend structure (React/Next.js or Vue)
- Create Docker Compose configuration
- Configure development environment
- Set up testing frameworks
- Configure linters and formatters

**Required Secrets**: None

**Definition of Done**:
- [ ] Project structure created
- [ ] Dependencies defined (requirements.txt, package.json)
- [ ] Docker Compose builds successfully
- [ ] Basic health check endpoints work
- [ ] Testing framework configured
- [ ] Linters configured

---

### Phase 1: Core Backend API
**Scope**: Implement core backend functionality

**Tasks**:
- Database models and migrations
- API endpoints (CRUD operations)
- Authentication/Authorization
- Input validation
- Error handling
- Unit tests for all endpoints

**Required Secrets**:
- Database credentials
- JWT secret keys
- API keys (if external services needed)

**Definition of Done**:
- [ ] All endpoints implemented
- [ ] Tests pass (>80% coverage)
- [ ] API documentation generated
- [ ] Authentication working
- [ ] Error handling comprehensive
- [ ] Database migrations working

---

### Phase 2: Frontend Implementation
**Scope**: Build frontend user interface

**Tasks**:
- Component structure
- State management setup
- API integration
- Forms and validation
- Authentication flow
- Responsive design
- Component tests

**Required Secrets**:
- API endpoint URLs
- Auth tokens/keys

**Definition of Done**:
- [ ] All components implemented
- [ ] Build passes without errors
- [ ] API integration working
- [ ] Authentication flow complete
- [ ] Responsive on mobile/tablet/desktop
- [ ] No console errors

---

### Phase 3: Integration & Testing
**Scope**: End-to-end integration and comprehensive testing

**Tasks**:
- Integration tests
- E2E tests (if Cypress/Playwright configured)
- Performance testing
- Error scenarios testing
- Security testing
- Load testing (if applicable)

**Required Secrets**: Same as previous phases

**Definition of Done**:
- [ ] All integration tests passing
- [ ] E2E tests passing
- [ ] No critical security issues
- [ ] Performance benchmarks met
- [ ] Error handling verified
- [ ] Edge cases tested

---

### Phase 4: Production Readiness
**Scope**: Prepare for production deployment

**Tasks**:
- Environment configuration
- Logging and monitoring setup
- Security hardening
- Performance optimization
- Documentation completion
- Deployment scripts

**Required Secrets**:
- Production database credentials
- Production API keys
- SSL certificates (if applicable)
- Cloud provider credentials

**Definition of Done**:
- [ ] Production environment configured
- [ ] Logging working
- [ ] Monitoring in place
- [ ] Security audit passed
- [ ] Documentation complete
- [ ] Deployment tested
- [ ] Rollback procedure documented

---

## Testing Standards

### Backend Tests
- Minimum 80% code coverage
- All endpoints must have tests
- Include positive and negative test cases
- Test authentication/authorization
- Test error handling
- Use fixtures for test data

### Frontend Tests
- Component unit tests
- Integration tests for key flows
- Accessibility testing
- Cross-browser compatibility
- Responsive design testing

### Integration Tests
- Test full user flows
- Test error scenarios
- Test database transactions
- Test API contract compliance

---

## Code Quality Standards

### Backend
- Follow PEP 8 (Python)
- Use type hints
- Document functions with docstrings
- Handle exceptions properly
- Use environment variables for config
- Keep functions small and focused

### Frontend
- Follow ESLint rules
- Use TypeScript (preferred)
- Component documentation
- Consistent naming conventions
- Accessibility compliance (WCAG)
- Optimize bundle size

### Docker
- Multi-stage builds
- Minimal base images
- Security scanning
- Health checks defined
- Resource limits set

---

## Common Commands Reference

### Backend Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run development server
python manage.py runserver  # Django
uvicorn main:app --reload   # FastAPI

# Run tests
pytest -v --cov=. --cov-report=html

# Format code
black .
isort .

# Lint code
flake8 .
pylint .
mypy .

# Database migrations
python manage.py makemigrations
python manage.py migrate
```

### Frontend Development
```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Run tests
npm test
npm run test:coverage

# Lint and format
npm run lint
npm run format
```

### Docker Operations
```bash
# Build all services
docker compose build

# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f [service-name]

# Rebuild specific service
docker compose build [service-name]

# Execute commands in container
docker compose exec [service-name] [command]
```

### Git Operations
```bash
# Create and switch to feature branch
git checkout -b feature/branch-name

# Stage changes
git add .

# Commit with message
git commit -m "descriptive message"

# Push to remote
git push -u origin feature/branch-name

# View status
git status

# View diff
git diff
```

---

## Troubleshooting Guide

### Docker Issues
- **Containers won't start**: Check logs with `docker compose logs`
- **Port conflicts**: Check if ports are already in use
- **Build fails**: Clear cache with `docker compose build --no-cache`

### Backend Issues
- **Import errors**: Verify virtual environment is activated
- **Database errors**: Check migrations are applied
- **Tests failing**: Check test database is configured

### Frontend Issues
- **Build fails**: Clear node_modules and reinstall
- **Module not found**: Run `npm install`
- **Port in use**: Change port in configuration

---

## Best Practices

1. **Always read existing code** before making changes
2. **Write tests first** (TDD approach preferred)
3. **Commit frequently** with descriptive messages
4. **Never skip verification** steps
5. **Ask for secrets** when needed, don't guess
6. **Document as you go**, not at the end
7. **Keep changes focused** on current phase
8. **Run linters** before committing
9. **Check Docker logs** if services fail
10. **Update this file** if process changes

---

## Emergency Procedures

### If Tests Fail
1. Read the error messages carefully
2. Check recent changes
3. Run specific failing test in isolation
4. Fix the issue
5. Re-run all tests
6. DO NOT proceed to next phase with failing tests

### If Build Fails
1. Check error logs
2. Verify all dependencies installed
3. Clear build cache
4. Try clean build
5. Fix configuration issues
6. DO NOT mark phase complete with broken build

### If Docker Issues
1. Check container logs: `docker compose logs`
2. Verify .env file present
3. Check port conflicts
4. Rebuild containers: `docker compose build --no-cache`
5. Check disk space and resources
6. DO NOT proceed with broken infrastructure

---

## Notes for AI Agents

- **Be thorough**: Complete all verification steps
- **Be honest**: Report failures accurately
- **Be focused**: Stay within phase scope
- **Be clear**: Provide detailed output summaries
- **Be patient**: Wait for user approval between phases
- **Be proactive**: Run tests yourself, don't ask user to do it
- **Be responsible**: Never commit secrets or untested code

---

## Version History

- v1.0 (2026-02-04): Initial AGENTS.md created with phase-based development process

---

## Questions?

If anything is unclear or you encounter situations not covered in this document:
1. Document the issue
2. Ask the user for clarification
3. Update this document with the resolution
