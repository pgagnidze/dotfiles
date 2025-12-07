# Python Style Guide

Style conventions for Python code in this project. Based on PEP 8 and Google Python Style Guide.

## Tooling

Use uv for package management:

```bash
uv venv                    # Create virtual environment
uv pip install -e ".[dev]" # Install with dev dependencies
uv sync                    # Sync from lockfile
uv add fastapi             # Add dependency
uv add --dev pytest        # Add dev dependency
```

Use ruff for linting and formatting:

```bash
ruff check .
ruff format .
```

Configuration in `pyproject.toml`:

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # pyflakes
    "I",      # isort
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "UP",     # pyupgrade
    "SIM",    # flake8-simplify
]
ignore = [
    "E501",   # line too long (handled by formatter)
]

[tool.ruff.lint.isort]
known-first-party = ["app"]
```

Use mypy for type checking:

```bash
mypy .
```

Configuration in `pyproject.toml`:

```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_ignores = true
```

## Comments

Avoid comments. Code should be self-explanatory through clear naming and structure.

If logic isn't obvious, refactor into a well-named function instead of adding a comment.

Use `TODO` and `FIXME` tags when needed:

```python
# TODO: Add retry logic
# FIXME: Handle edge case when list is empty
```

## Structure

Organize modules in this order:

1. Module docstring
2. `from __future__` imports
3. Standard library imports
4. Third-party imports
5. Local imports
6. Constants
7. Classes and functions
8. `if __name__ == "__main__"` block

```python
"""Module for handling user sessions."""

from __future__ import annotations

import asyncio
from typing import Any

from fastapi import HTTPException
from pydantic import BaseModel

from app.database import get_db

MAX_SESSIONS = 100

class Session:
    pass

def create_session() -> Session:
    pass

if __name__ == "__main__":
    main()
```

## Imports

One import per line. Group imports with blank lines between groups:

```python
# good
import os
import sys

from fastapi import FastAPI
from pydantic import BaseModel

from app.models import User

# bad
import os, sys
from fastapi import FastAPI, HTTPException, Depends
```

Use absolute imports. Avoid wildcard imports:

```python
# good
from app.services import session_manager

# bad
from .services import session_manager
from app.services import *
```

## Formatting

Use 4 spaces. No tabs. Line length is 100 characters.

```python
def long_function_name(
    var_one: int,
    var_two: str,
    var_three: float,
) -> dict[str, Any]:
    return {"result": var_one}
```

Break before binary operators:

```python
# good
income = (gross_wages
          + taxable_interest
          - ira_deduction)

# bad
income = (gross_wages +
          taxable_interest -
          ira_deduction)
```

Use trailing commas in multi-line structures:

```python
# good
config = {
    "host": "localhost",
    "port": 8000,
}

# bad
config = {
    "host": "localhost",
    "port": 8000
}
```

Two blank lines around top-level definitions. One blank line between methods:

```python
def function_one():
    pass


def function_two():
    pass


class MyClass:
    def method_one(self):
        pass

    def method_two(self):
        pass
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Module | `lower_case` | `session_manager.py` |
| Package | `lower_case` | `app/services/` |
| Class | `PascalCase` | `SessionManager` |
| Exception | `PascalCase` + Error | `SessionNotFoundError` |
| Function | `lower_case` | `create_session()` |
| Method | `lower_case` | `get_messages()` |
| Variable | `lower_case` | `user_count` |
| Constant | `UPPER_CASE` | `MAX_CONNECTIONS` |
| Type variable | `PascalCase` | `T`, `ResponseT` |

Private names use single underscore prefix:

```python
class Session:
    def __init__(self):
        self._internal_state = {}  # private

    def _helper_method(self):  # private
        pass
```

Avoid single-letter names except for:
- Loop counters: `i`, `j`, `k`
- Exception handlers: `e`
- File handles: `f`
- Generic types: `T`

## Strings

Use double quotes for strings. Use single quotes to avoid escaping:

```python
message = "Hello, world"
html = '<div class="container">'
```

Use f-strings for formatting:

```python
# good
name = "Alice"
greeting = f"Hello, {name}!"

# bad
greeting = "Hello, " + name + "!"
greeting = "Hello, {}!".format(name)
greeting = "Hello, %s!" % name
```

Use triple double quotes for docstrings and multi-line strings:

```python
"""This is a docstring."""

query = """
    SELECT *
    FROM users
    WHERE active = true
"""
```

## Type Annotations

Always use type annotations for function signatures:

```python
def create_session(user_id: str, config: dict[str, Any] | None = None) -> Session:
    pass

async def fetch_data(url: str) -> list[dict[str, Any]]:
    pass
```

Use `|` for union types (Python 3.10+):

```python
# good
def process(value: str | int | None) -> str:
    pass

# avoid (older style)
from typing import Union, Optional
def process(value: Union[str, int, Optional[float]]) -> str:
    pass
```

Use built-in generics instead of `typing` module:

```python
# good
def get_items() -> list[str]:
    pass

def get_mapping() -> dict[str, int]:
    pass

# avoid
from typing import List, Dict
def get_items() -> List[str]:
    pass
```

Annotate class attributes:

```python
class Session:
    id: str
    messages: list[Message]
    created_at: datetime

    def __init__(self, id: str) -> None:
        self.id = id
        self.messages = []
        self.created_at = datetime.now()
```

## Functions

Keep functions short and focused. If a function exceeds 40 lines, consider splitting it.

Return early for validation:

```python
def process_user(user: User | None) -> str:
    if user is None:
        return "anonymous"

    if not user.is_active:
        return "inactive"

    return user.name
```

Use keyword arguments for clarity:

```python
# good
create_session(user_id="123", timeout=30, retry=True)

# bad
create_session("123", 30, True)
```

Default arguments must be immutable:

```python
# good
def add_items(items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    return items

# bad - mutable default
def add_items(items: list[str] = []) -> list[str]:
    return items
```

## Classes

Use dataclasses for simple data containers:

```python
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float

@dataclass(frozen=True)
class Config:
    host: str
    port: int = 8000
```

Use Pydantic for validation:

```python
from pydantic import BaseModel, Field

class SessionCreate(BaseModel):
    title: str = Field(min_length=1, max_length=100)
    model: str = "claude-sonnet-4-5-20250929"
```

Prefer composition over inheritance:

```python
# good
class SessionManager:
    def __init__(self, db: Database):
        self.db = db

# avoid deep inheritance
class SessionManager(BaseManager, LoggingMixin, CacheMixin):
    pass
```

## Conditionals

Use implicit boolean evaluation:

```python
# good
if items:
    process(items)

if not name:
    name = "default"

# bad
if len(items) > 0:
    process(items)

if name == "":
    name = "default"
```

Use `is` for `None` comparisons:

```python
# good
if value is None:
    pass

if result is not None:
    pass

# bad
if value == None:
    pass
```

Avoid nested conditionals:

```python
# good
def validate(data):
    if not data:
        return False
    if not data.get("id"):
        return False
    if not data.get("name"):
        return False
    return True

# bad
def validate(data):
    if data:
        if data.get("id"):
            if data.get("name"):
                return True
    return False
```

## Comprehensions

Use comprehensions for simple transformations:

```python
# good
squares = [x ** 2 for x in range(10)]
active_users = {u.id: u for u in users if u.is_active}

# bad - too complex
result = [
    transform(x, y)
    for x in range(10)
    for y in range(10)
    if x != y
    if is_valid(x, y)
]
```

Split complex comprehensions into loops:

```python
# good
result = []
for x in range(10):
    for y in range(10):
        if x != y and is_valid(x, y):
            result.append(transform(x, y))
```

## Error Handling

Catch specific exceptions:

```python
# good
try:
    value = data["key"]
except KeyError:
    value = default

# bad
try:
    value = data["key"]
except:
    value = default
```

Use custom exceptions for domain errors:

```python
class SessionError(Exception):
    """Base exception for session errors."""

class SessionNotFoundError(SessionError):
    """Raised when session does not exist."""

class SessionExpiredError(SessionError):
    """Raised when session has expired."""
```

Keep try blocks minimal:

```python
# good
try:
    value = collection[key]
except KeyError:
    return handle_missing(key)
else:
    return process(value)

# bad
try:
    value = collection[key]
    return process(value)
except KeyError:
    return handle_missing(key)
```

## Context Managers

Use `with` for resource management:

```python
# good
with open("file.txt") as f:
    content = f.read()

async with session.begin():
    session.add(record)

# bad
f = open("file.txt")
content = f.read()
f.close()
```

## Async

Use `async`/`await` consistently:

```python
async def fetch_all(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_one(session, url) for url in urls]
        return await asyncio.gather(*tasks)

async def fetch_one(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url) as response:
        return await response.json()
```

Don't mix sync and async:

```python
# good
async def get_data():
    return await async_fetch()

# bad - blocking call in async function
async def get_data():
    return requests.get(url)  # blocks event loop
```

## Docstrings

Use Google style docstrings for public APIs:

```python
def create_session(
    user_id: str,
    model: str = "claude-sonnet-4-5-20250929",
) -> Session:
    """Create a new agent session.

    Args:
        user_id: The ID of the user creating the session.
        model: The Claude model to use.

    Returns:
        A new Session instance.

    Raises:
        ValueError: If user_id is empty.
        SessionLimitError: If user has too many active sessions.
    """
```

Keep docstrings concise. Skip for simple/obvious functions:

```python
# no docstring needed
def get_user_count() -> int:
    return len(self.users)

def is_valid(value: str) -> bool:
    return bool(value and value.strip())
```

## Logging

Use structured logging:

```python
import logging

logger = logging.getLogger(__name__)

# good
logger.info("Session created", extra={"session_id": session.id, "user": user_id})
logger.error("Failed to connect", extra={"url": url, "error": str(e)})

# bad
logger.info(f"Session {session.id} created for user {user_id}")
```

Use appropriate log levels:
- `DEBUG`: Detailed diagnostic information
- `INFO`: General operational events
- `WARNING`: Unexpected but handled situations
- `ERROR`: Errors that need attention
- `CRITICAL`: System failures

## Testing

Use pytest. Name test files `test_*.py`:

```python
# test_session.py
import pytest
from app.services import SessionManager

class TestSessionManager:
    def test_create_session_success(self):
        manager = SessionManager()
        session = manager.create("user-123")
        assert session.id is not None
        assert session.user_id == "user-123"

    def test_create_session_invalid_user(self):
        manager = SessionManager()
        with pytest.raises(ValueError):
            manager.create("")
```

Use fixtures for setup:

```python
@pytest.fixture
def db():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    yield Session(engine)
    engine.dispose()

@pytest.fixture
def session_manager(db):
    return SessionManager(db)

def test_create_session(session_manager):
    session = session_manager.create("user-123")
    assert session is not None
```

## Project Structure

```
project/
    app/
        __init__.py
        main.py           # Entry point
        config.py         # Configuration
        database.py       # Database setup
        models/           # SQLAlchemy models
            __init__.py
            session.py
        schemas/          # Pydantic schemas
            __init__.py
            session.py
        api/              # API endpoints
            __init__.py
            sessions.py
        services/         # Business logic
            __init__.py
            session_manager.py
    tests/
        __init__.py
        conftest.py       # Fixtures
        test_sessions.py
    pyproject.toml
    README.md
```

## Dependencies

Specify in `pyproject.toml`:

```toml
[project]
name = "computer-use-hub"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.109.0",
    "uvicorn[standard]>=0.27.0",
    "sqlalchemy>=2.0.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "ruff>=0.3.0",
    "mypy>=1.8.0",
]
```

## Makefile

```makefile
.PHONY: install lint format test typecheck check

install:
	uv sync

lint:
	uv run ruff check .

format:
	uv run ruff format .

test:
	uv run pytest

typecheck:
	uv run mypy .

check: lint typecheck test
```

## References

- https://peps.python.org/pep-0008/
- https://google.github.io/styleguide/pyguide.html
- https://docs.astral.sh/ruff/
- https://docs.astral.sh/uv/
