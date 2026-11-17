# Job System Design Document

## Overview
The goal of the job system is to handle asynchronous API requests that need to be executed in a controlled sequence. The system must manage sending requests, waiting for responses, handling failures (with retries), and updating statuses in real-time.

## Current Status & Placeholder Implementation
Currently, the `QueueRepository` handles basic enqueuing of items into a local database (`queue_items` table).

The execution logic is currently a placeholder:
1. **Enqueue**: Items are added to the DB with status `PENDING`.
2. **Tracker**: The UI polls/streams these items from the DB.
3. **Missing**: There is no background worker or "Executor" that actually picks up `PENDING` jobs, moves them to `SENDING`, waits for the API response, and updates them to `COMPLETED` or `FAILED`.

## Proposed Design Architecture

To move beyond the placeholder, we need a multi-layered approach:

### 1. Job Executor (The Worker)
A dedicated singleton service responsible for processing the queue.
- **Responsibility**: Monitor the `queue_items` table for jobs with status `PENDING`.
- **Concurrency Control**: Manage how many jobs can run in parallel (e.g., a pool of workers).
- **Lifecycle Management**:
    - Pick a job -> Update to `SENDING`.
    - Execute API Call -> Await Response.
    - Success -> Update to `COMPLETED`.
    - Failure -> Increment `retryCount`, update `errorMessage`, and if retries remain, set back to `PENDING` (or move to a delayed queue).

### 2. Job Manager / Orchestrator
A high-level API for the UI or other services to interact with jobs.
- **Methods**:
    - `submitJob(payload, priority)`: Returns a `jobId`.
    - `getJobStatus(jobId)`: Returns current status and progress.
    - `cancelJob(jobId)`: Removes job from the active processing list.

### 3. API Integration Layer
A dedicated layer to map `JobType` to specific network requests.
- For each `JobType`, define the endpoint, headers, and mapping logic for the payload $\leftrightarrow$ request body.

## Implementation Strategy

### Phase 1: The Executor Skeleton
- Create a `JobExecutor` class.
- Implement a simple loop that checks the database every $X$ milliseconds for `PENDING` jobs where `status != SENDING`.
- Add a "Locking" mechanism (e.g., a `locked_at` timestamp or a dedicated `is_processing` flag) to ensure multiple workers don't grab the same job simultaneously.

### Phase 2: API Mapping & Concurrency
- Define an abstract `BaseJobTask`.
- Create specific implementations (e.g., `FillInRequestTask`).
- Implement a `WorkerPool` to limit concurrent requests (e.g., max 3 at a time).

### Phase 3: Error Handling & Retries
- Implement exponential backoff for retries.
- Log detailed errors in the `errorMessage` field of the database.

## Database Schema Requirements (Additions/Changes)
To support the full design, we may need to add:
- `is_processing`: Boolean flag or `last_updated_at` timestamp.
- `next_retry_at`: Timestamp for scheduled retries.
- `worker_id`: To track which worker instance is handling which job (useful for multi-instance scaling).
