include .env
export

MIGRATE = migrate -path db/migrations -database "$(DATABASE_URL)"

.PHONY: up down migrate-up migrate-down migrate-new run-api

up:
	docker-compose up -d

down:
	docker-compose down

migrate-up:
	$(MIGRATE) up

migrate-down:
	$(MIGRATE) down 1

migrate-new:
	migrate create -ext sql -dir db/migrations -seq $(name)

run-api:
	go run ./cmd/api
