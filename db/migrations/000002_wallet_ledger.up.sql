CREATE TABLE wallets (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    uuid REFERENCES users(id),
    kind       text NOT NULL CHECK (kind IN ('USER', 'SYSTEM')),
    currency   text NOT NULL,
    balance    bigint NOT NULL DEFAULT 0,
    version    int NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT wallet_owner_chk CHECK (
        (kind = 'USER' AND user_id IS NOT NULL) OR
        (kind = 'SYSTEM' AND user_id IS NULL)
    ),
    -- hanya wallet USER yang tidak boleh minus
    CONSTRAINT wallet_balance_chk CHECK (kind = 'SYSTEM' OR balance >= 0)
);

CREATE UNIQUE INDEX wallets_user_currency_uq
    ON wallets (user_id, currency) WHERE kind = 'USER';
CREATE UNIQUE INDEX wallets_system_currency_uq
    ON wallets (currency) WHERE kind = 'SYSTEM';

CREATE TABLE transactions (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type       text NOT NULL CHECK (type IN ('TOPUP', 'TRANSFER')),
    status     text NOT NULL CHECK (status IN ('POSTED', 'FAILED')),
    reference  text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ledger_entries (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id uuid NOT NULL REFERENCES transactions(id),
    wallet_id      uuid NOT NULL REFERENCES wallets(id),
    direction      text NOT NULL CHECK (direction IN ('DEBIT', 'CREDIT')),
    amount         bigint NOT NULL CHECK (amount > 0),
    created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ledger_wallet_time_idx
    ON ledger_entries (wallet_id, created_at DESC, id);
CREATE INDEX ledger_transaction_idx
    ON ledger_entries (transaction_id);
