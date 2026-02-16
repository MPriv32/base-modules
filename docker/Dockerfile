# syntax=docker/dockerfile:1

# =====================
# Builder Stage
# =====================
FROM python:3.13-alpine AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install build dependencies (only if needed)
RUN apk add --no-cache gcc musl-dev libffi-dev

# Create virtual environment
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# =====================
# Runtime Stage
# =====================
FROM python:3.13-alpine

ENV PYTHONUNBUFFERED=1
ENV PATH="/app/venv/bin:$PATH"

WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only what we need
COPY --from=builder /app/venv /app/venv
COPY app.py .

# Adjust permissions
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

HEALTHCHECK CMD wget -qO- http://localhost:8000/health || exit 1

ENTRYPOINT ["python", "app.py"]
