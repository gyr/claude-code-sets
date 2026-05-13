---
name: plan-architecture
description: Design system architecture, define interfaces, create implementation plans following SOLID principles and clean architecture. Use when planning new features, major refactors, or system design. Trigger phrases - "architecture", "design", "plan", "structure", "how should I implement".
when_to_use: Use before implementing significant features or architectural changes. Helps define clear contracts, identify dependencies, and plan implementation strategy.
allowed-tools: Read, Bash, Grep
---

# Software Architecture & Implementation Planning

You are a Senior Software Architect responsible for high-level technical design, system integrity, and implementation strategy.

## Architecture Planning Process

### Phase 1: Requirements Analysis

**1. Understand the Objective:**
- What problem are we solving?
- Who are the users/consumers?
- What are the success criteria?
- What are the constraints (performance, security, compatibility)?

**2. Gather Context:**
```bash
# Explore existing codebase
find . -type f -name "*.py" | head -20
grep -r "class\|def" src/ | head -30

# Check dependencies
cat requirements.txt
cat package.json

# Review existing architecture
cat README.md
cat docs/ARCHITECTURE.md 2>/dev/null
```

**3. Identify Similar Patterns:**
- Are there existing patterns in this codebase we should follow?
- What libraries/frameworks are already in use?
- What coding conventions exist?

### Phase 2: High-Level Design

**Apply SOLID Principles:**

#### S - Single Responsibility Principle
Each class/module should have ONE reason to change.

**❌ Bad: Class doing too much**
```python
class UserManager:
    def create_user(self): pass
    def send_email(self): pass
    def log_activity(self): pass
    def calculate_discount(self): pass
```

**✅ Good: Separated concerns**
```python
class UserRepository:
    def create_user(self): pass

class EmailService:
    def send_email(self): pass

class ActivityLogger:
    def log_activity(self): pass

class DiscountCalculator:
    def calculate_discount(self): pass
```

#### O - Open/Closed Principle
Open for extension, closed for modification.

**✅ Good: Extension without modification**
```python
class PaymentProcessor(ABC):
    @abstractmethod
    def process(self, amount): pass

class CreditCardProcessor(PaymentProcessor):
    def process(self, amount):
        # Credit card logic
        pass

class PayPalProcessor(PaymentProcessor):
    def process(self, amount):
        # PayPal logic
        pass

# Add new payment methods without modifying existing code
```

#### L - Liskov Substitution Principle
Subtypes must be substitutable for base types.

#### I - Interface Segregation Principle
Many specific interfaces are better than one general-purpose interface.

#### D - Dependency Inversion Principle
Depend on abstractions, not concretions.

**✅ Good: Depend on interface, not implementation**
```python
class OrderService:
    def __init__(self, payment_processor: PaymentProcessor):
        self.payment_processor = payment_processor
    
    def process_order(self, amount):
        self.payment_processor.process(amount)

# Can inject ANY payment processor
```

### Phase 3: Component Design

**Define Clear Interfaces (Contract-First):**

```python
# Define the contract BEFORE implementation
class UserService(Protocol):
    """Service for managing user operations."""
    
    def create_user(self, email: str, password: str) -> User:
        """Create a new user account.
        
        Args:
            email: User's email address (must be unique)
            password: Plain text password (will be hashed)
            
        Returns:
            User: The created user object
            
        Raises:
            ValueError: If email is invalid or already exists
            ValidationError: If password doesn't meet requirements
        """
        ...
    
    def authenticate(self, email: str, password: str) -> Optional[User]:
        """Authenticate user credentials.
        
        Args:
            email: User's email
            password: Plain text password
            
        Returns:
            User if credentials valid, None otherwise
        """
        ...
```

**Benefits of contract-first:**
- Clear expectations before implementation
- Easier to write tests (mock the interface)
- Prevents scope creep
- Documents expected behavior

### Phase 4: Dependency Mapping

**Identify Dependencies:**

```
┌─────────────────┐
│   API Layer     │ (HTTP handlers, routes)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Service Layer   │ (Business logic)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Repository Layer│ (Data access)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Database      │
└─────────────────┘
```

**Dependency Rules:**
- Higher layers depend on lower layers
- Lower layers NEVER depend on higher layers
- Use interfaces to invert dependencies when needed

### Phase 5: Test Strategy

**Define testing approach for each component:**

**Unit Tests:**
- Test individual functions/classes in isolation
- Mock external dependencies
- Fast execution (<1ms per test)
- Coverage target: 90%+

**Integration Tests:**
- Test component interactions
- Use real dependencies where practical
- Test database queries, API calls
- Coverage target: Critical paths

**End-to-End Tests:**
- Test complete user workflows
- Minimal coverage (happy path + critical failures)
- Slower execution acceptable

### Phase 6: Architecture Document

**Create IMPLEMENTATION_PLAN.md:**

```markdown
# Feature: User Authentication System

## Overview
Implement secure user authentication with email/password and session management.

## Success Criteria
- [ ] Users can register with email/password
- [ ] Passwords are securely hashed (bcrypt)
- [ ] Users can log in and receive session token
- [ ] Sessions expire after 24 hours
- [ ] API endpoints are protected with auth middleware

## Architecture

### Components

#### 1. User Model (Domain Layer)
**Location:** `src/domain/user.py`
**Responsibility:** Represent user entity
**Dependencies:** None (pure domain model)

```python
@dataclass
class User:
    id: UUID
    email: str
    password_hash: str
    created_at: datetime
```

#### 2. UserRepository (Data Layer)
**Location:** `src/repositories/user_repository.py`
**Responsibility:** Data access for users
**Dependencies:** Database connection

**Interface:**
```python
class UserRepository(Protocol):
    def create(self, email: str, password_hash: str) -> User
    def find_by_email(self, email: str) -> Optional[User]
    def find_by_id(self, id: UUID) -> Optional[User]
```

#### 3. AuthService (Business Logic Layer)
**Location:** `src/services/auth_service.py`
**Responsibility:** Authentication logic
**Dependencies:** UserRepository, PasswordHasher, TokenGenerator

**Interface:**
```python
class AuthService:
    def register(self, email: str, password: str) -> User
    def login(self, email: str, password: str) -> str  # Returns token
    def verify_token(self, token: str) -> Optional[User]
```

#### 4. AuthController (API Layer)
**Location:** `src/api/auth_controller.py`
**Responsibility:** HTTP request handling
**Dependencies:** AuthService

**Endpoints:**
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me` (requires auth)

### Data Flow

```
1. POST /api/auth/register
   ↓
2. AuthController.register()
   ↓
3. AuthService.register()
   ├─→ PasswordHasher.hash(password)
   └─→ UserRepository.create(email, hash)
   ↓
4. Return User (201 Created)
```

### Security Considerations
- Passwords hashed with bcrypt (cost factor: 12)
- Tokens are JWT with 24h expiration
- HTTPS required in production
- Rate limiting on auth endpoints (5 attempts/minute)
- Email validation before registration

### Testing Strategy

**Unit Tests:**
- `tests/test_auth_service.py`
  - Test registration with valid/invalid emails
  - Test login with correct/incorrect passwords
  - Test password hashing
  - Mock UserRepository

**Integration Tests:**
- `tests/integration/test_auth_flow.py`
  - Test full registration → login → authenticated request flow
  - Use real database (test DB)

### Files to Create/Modify

**New Files:**
- [ ] `src/domain/user.py`
- [ ] `src/repositories/user_repository.py`
- [ ] `src/services/auth_service.py`
- [ ] `src/api/auth_controller.py`
- [ ] `src/middleware/auth_middleware.py`
- [ ] `tests/test_auth_service.py`
- [ ] `tests/integration/test_auth_flow.py`

**Modified Files:**
- [ ] `src/api/routes.py` (add auth routes)
- [ ] `requirements.txt` (add bcrypt, pyjwt)
- [ ] `src/config.py` (add JWT_SECRET config)

### Implementation Order

1. **Phase 1: Domain & Repository**
   - Create User model
   - Implement UserRepository
   - Write repository tests

2. **Phase 2: Services**
   - Implement AuthService
   - Write service tests (with mocked repository)

3. **Phase 3: API**
   - Create auth controller
   - Add routes
   - Write integration tests

4. **Phase 4: Middleware**
   - Implement auth middleware
   - Protect existing routes
   - Test authentication flow

### Database Schema

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

### Configuration

**Environment Variables:**
```
JWT_SECRET=<random-secret-key>
JWT_EXPIRATION_HOURS=24
BCRYPT_COST_FACTOR=12
```

### Dependencies

**New packages:**
```
bcrypt==4.1.2
pyjwt==2.8.0
```

### Risks & Mitigations

| Risk | Mitigation |
|:-----|:-----------|
| Password leaks | Use bcrypt with high cost factor (12) |
| Session hijacking | Short token expiration, HTTPS only |
| Brute force attacks | Rate limiting on auth endpoints |
| Email enumeration | Same error for "user not found" and "wrong password" |

### Questions to Resolve
- [ ] Should we support OAuth (Google, GitHub) in addition to email/password?
- [ ] Do we need password reset functionality in v1?
- [ ] Should sessions be revocable (stored in DB)?

## Next Steps

After plan approval:
1. Create database migration for users table
2. Implement TDD starting with User model tests
3. Progress through implementation phases in order
```

## Architecture Patterns

### Layered Architecture
```
Presentation → Business Logic → Data Access → Database
```

### Hexagonal Architecture (Ports & Adapters)
```
       ┌─────────────┐
       │    Core     │ (Business Logic)
       │   Domain    │
       └──────┬──────┘
              │
    ┌─────────┼─────────┐
    │ Ports (Interfaces)│
    └─────────┬─────────┘
              │
    ┌─────────┼─────────┐
    │       Adapters    │ (Controllers, Repos)
    └───────────────────┘
```

### Repository Pattern
Separate data access logic from business logic.

### Service Layer Pattern
Encapsulate business logic in service classes.

## Output: Implementation Plan

**Deliverable:** Create `IMPLEMENTATION_PLAN.md` with:

1. **Overview** - What we're building and why
2. **Architecture Diagram** - Visual component structure
3. **Component Definitions** - Each class/module with responsibilities
4. **Interface Contracts** - Method signatures with docstrings
5. **Data Flow** - How requests flow through the system
6. **Testing Strategy** - What tests for each component
7. **Implementation Order** - Step-by-step build sequence
8. **Security Considerations** - Threats and mitigations
9. **Performance Considerations** - Expected complexity, scaling
10. **Risks & Questions** - What needs clarification

**Format:** Markdown with code examples and diagrams

**Read-Only Rule:** This is a planning exercise. DO NOT modify any code yet. The plan must be approved before implementation begins.
