CREATE TABLE idempotency_keys (
    user_id       uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    key           text NOT NULL,
    request_hash  text NOT NULL,
    status_code   int,
    response_body jsonb,
    created_at    timestamptz NOT NULL DEFAULT now(),
    expires_at    timestamptz NOT NULL,
    PRIMARY KEY (user_id, key)
);

CREATE INDEX idempotency_expires_idx ON idempotency_keys (expires_at);

CREATE TABLE outbox_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id  uuid REFERENCES transactions(id),
    event_type      text NOT NULL,
    payload         jsonb NOT NULL,
    status          text NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING', 'SENT', 'DEAD')),
    attempts        int NOT NULL DEFAULT 0,
    next_attempt_at timestamptz NOT NULL DEFAULT now(),
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX outbox_pending_idx
    ON outbox_events (next_attempt_at) WHERE status = 'PENDING';

CREATE TABLE webhook_endpoints (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    url        text NOT NULL,
    secret     text NOT NULL,
    active     boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE webhook_deliveries (
    id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id     uuid NOT NULL REFERENCES outbox_events(id) ON DELETE CASCADE,
    endpoint_id  uuid NOT NULL REFERENCES webhook_endpoints(id) ON DELETE CASCADE,
    status       text NOT NULL DEFAULT 'PENDING',
    attempts     int NOT NULL DEFAULT 0,
    last_error   text,
    delivered_at timestamptz,
    UNIQUE (event_id, endpoint_id)
);
