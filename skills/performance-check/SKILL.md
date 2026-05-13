---
name: performance-check
description: Analyze algorithmic complexity, identify performance bottlenecks, and suggest optimizations based on profiling data. Use when performance issues arise or when optimizing code. Trigger phrases - "slow", "performance", "optimize", "Big-O", "bottleneck", "profile".
when_to_use: Use when code performance is a concern, or proactively for code that processes large datasets or runs frequently. Always profile before suggesting optimizations.
allowed-tools: Read, Bash, Grep
---

# Performance Analysis & Optimization

You are a Performance Engineering Specialist. Your goal is to identify and fix performance bottlenecks based on data, not assumptions.

## The Golden Rule

**NO MANUAL OPTIMIZATION WITHOUT DATA**

Never suggest optimizations unless:
1. A bottleneck has been identified via profiling, OR
2. There's a theoretical Big-O violation (O(n²) or worse on large datasets)

If an optimization makes code significantly harder to read for <5% gain, reject it.

## Performance Analysis Workflow

### Step 1: Establish Baseline

**Measure current performance:**

```bash
# Time the operation
time python -m src.main

# Profile with cProfile
python -m cProfile -o profile.stats -m src.main

# Analyze profiling results
python -m pstats profile.stats
# Then in pstats shell:
# sort cumtime
# stats 20
```

**Document baseline:**
- Execution time
- Memory usage
- Top 5 slowest functions

### Step 2: Algorithmic Complexity Analysis

**Analyze Big-O complexity of critical paths:**

**Target complexities:**
- ✅ O(1) - Constant time (hash table lookup, array access)
- ✅ O(log n) - Logarithmic (binary search)
- ✅ O(n) - Linear (single loop through data)
- ⚠️ O(n log n) - Linearithmic (efficient sorting)
- ❌ O(n²) - Quadratic (nested loops - AVOID)
- ❌ O(2ⁿ) - Exponential (recursive without memoization - AVOID)

**Common O(n²) violations:**
```python
# ❌ O(n²): Nested loop over same collection
for user in users:
    for permission in permissions:
        if permission.user_id == user.id:
            user.permissions.append(permission)

# ✅ O(n): Use dictionary for O(1) lookup
permission_map = {}
for permission in permissions:
    if permission.user_id not in permission_map:
        permission_map[permission.user_id] = []
    permission_map[permission.user_id].append(permission)

for user in users:
    user.permissions = permission_map.get(user.id, [])
```

### Step 3: Identify Bottlenecks

**Look for these patterns:**

**❌ List scans (O(n) lookup):**
```python
# Slow: O(n) for each lookup
if item in large_list:  # Scans entire list
    do_something()

# Fast: O(1) for each lookup
large_set = set(large_list)
if item in large_set:  # Hash lookup
    do_something()
```

**❌ Repeated database queries (N+1 problem):**
```python
# Slow: N+1 queries
users = User.all()
for user in users:
    posts = Post.where(user_id=user.id).all()  # Query in loop!

# Fast: 2 queries with join
users = User.all().include('posts')
for user in users:
    posts = user.posts  # Already loaded
```

**❌ Loading entire datasets into memory:**
```python
# Slow: Loads all records into memory
all_logs = Log.all()  # 10 million records
for log in all_logs:
    process(log)

# Fast: Use generator/iterator
for log in Log.iterate():  # Lazy loading
    process(log)
```

**❌ Inefficient string concatenation:**
```python
# Slow: Creates new string object each iteration
result = ""
for item in items:
    result += str(item)  # O(n²) behavior

# Fast: Join once at the end
result = "".join(str(item) for item in items)  # O(n)
```

### Step 4: Profile-Driven Optimization

**Use profilers to identify hot functions:**

**For CPU-bound code:**
```bash
# Profile execution time
python -m cProfile -s cumtime -m src.main

# Line-by-line profiling
pip install line_profiler
kernprof -l -v script.py
```

**For memory-bound code:**
```bash
# Profile memory usage
pip install memory_profiler
python -m memory_profiler script.py

# Or use mprof for graphical output
mprof run script.py
mprof plot
```

**Analyze profiling output:**
1. Sort by cumulative time (`cumtime`)
2. Identify functions taking >10% of total time
3. Prioritize optimizing the slowest functions first

### Step 5: Apply Optimizations

**Optimization strategies (in order of preference):**

#### 1. Algorithm Change (Biggest Impact)
Change the approach to reduce complexity:
- Replace O(n²) with O(n) or O(n log n)
- Use appropriate data structures (dict over list for lookups)
- Add caching/memoization for expensive repeated calculations

#### 2. Data Structure Selection
Choose the right data structure:
| Need | Slow Choice | Fast Choice |
|:-----|:------------|:------------|
| Membership testing | List | Set or Dict |
| Fast lookup by key | List | Dict |
| FIFO queue | List | collections.deque |
| Sorted data | List + sort | heapq or bisect |
| Counting | Dict loop | collections.Counter |

#### 3. Built-in Functions & Comprehensions
Use optimized built-ins (implemented in C):
```python
# Slow: Manual loop
result = []
for x in items:
    if condition(x):
        result.append(transform(x))

# Fast: List comprehension (C-optimized)
result = [transform(x) for x in items if condition(x)]

# Even faster for large data: Generator
result = (transform(x) for x in items if condition(x))
```

#### 4. Lazy Evaluation
Use generators to avoid loading everything into memory:
```python
# Slow: Materializes entire list
squares = [x**2 for x in range(1000000)]
for square in squares:
    process(square)

# Fast: Generate on demand
squares = (x**2 for x in range(1000000))
for square in squares:
    process(square)
```

#### 5. Caching & Memoization
Cache expensive computations:
```python
from functools import lru_cache

# Without cache: Recalculates every time
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# With cache: Calculates each value once
@lru_cache(maxsize=None)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```

### Step 6: Measure Impact

**After each optimization:**

```bash
# Run profiler again
python -m cProfile -o profile_after.stats -m src.main

# Compare before/after
python -c "
import pstats
before = pstats.Stats('profile.stats')
after = pstats.Stats('profile_after.stats')
print('BEFORE:', before.total_tt)
print('AFTER:', after.total_tt)
print('IMPROVEMENT:', (before.total_tt - after.total_tt) / before.total_tt * 100, '%')
"
```

**Document improvement:**
- % reduction in execution time
- % reduction in memory usage
- Change in Big-O complexity

### Step 7: Verify Correctness

**CRITICAL: Run tests after optimization**

```bash
# Run full test suite
pytest tests/ -v

# Run with coverage to ensure behavior unchanged
pytest --cov=src tests/
```

**Performance optimizations that break correctness are worthless.**

## Language-Specific Optimizations

### Python Performance Tips

**✅ Use built-ins (written in C):**
- `map()`, `filter()`, `sum()`, `any()`, `all()`
- `collections` module (Counter, defaultdict, deque)
- `itertools` for efficient iterations

**✅ Avoid repeated attribute lookup:**
```python
# Slow: Looks up str.upper every iteration
result = [s.upper() for s in strings]

# Fast: Lookup once
upper = str.upper
result = [upper(s) for s in strings]
```

**✅ Use `__slots__` for classes with many instances:**
```python
class Point:
    __slots__ = ['x', 'y']  # Reduces memory by ~40%
    def __init__(self, x, y):
        self.x = x
        self.y = y
```

## Performance Report Format

### Executive Summary
- **Baseline performance:** 45.2 seconds, 850 MB RAM
- **After optimization:** 2.3 seconds, 120 MB RAM
- **Improvement:** 95% faster, 86% less memory

### Bottlenecks Identified

**1. Hot Function: `process_users()` (67% of runtime)**
- **Issue:** O(n²) nested loop over users and permissions
- **Complexity:** O(n²) where n = 50,000 users
- **Fix:** Changed to dictionary lookup (O(n))
- **Impact:** 65% reduction in runtime

**2. Memory Leak: Loading entire log file**
- **Issue:** 10M log entries loaded into memory (2.5 GB)
- **Fix:** Changed to generator-based streaming
- **Impact:** 95% reduction in memory usage

### Optimizations Applied

| Function | Before | After | Improvement | Complexity Change |
|:---------|:-------|:------|:------------|:------------------|
| `process_users` | 30.5s | 2.1s | 93% faster | O(n²) → O(n) |
| `load_logs` | 2.5 GB | 120 MB | 95% less RAM | Eager → Lazy |
| `search_items` | 8.2s | 0.3s | 96% faster | List → Set |

### Code Changes

**Before:**
```python
def process_users(users, permissions):
    for user in users:  # O(n)
        for perm in permissions:  # O(n)
            if perm.user_id == user.id:  # O(n²) total
                user.add_permission(perm)
```

**After:**
```python
def process_users(users, permissions):
    perm_map = defaultdict(list)
    for perm in permissions:  # O(n)
        perm_map[perm.user_id].append(perm)
    
    for user in users:  # O(n)
        for perm in perm_map.get(user.id, []):  # O(1) lookup
            user.add_permission(perm)
    # Total: O(n)
```

### Profiling Evidence

```
Before optimization:
   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1   30.452   30.452   30.452   30.452 process.py:23(process_users)

After optimization:
   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    2.103    2.103    2.103    2.103 process.py:23(process_users)
```

### Recommendations

1. ✅ All critical bottlenecks addressed
2. ⚠️ Consider adding caching for `calculate_score()` (called 10K+ times)
3. ℹ️ Database query optimization out of scope (no ORM queries in profile)

### Next Steps

- [ ] Deploy to staging for load testing
- [ ] Monitor production metrics for regression
- [ ] Set up continuous profiling to catch future regressions
