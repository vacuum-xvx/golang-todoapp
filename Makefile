include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@read -p "Очистить все volumes? (y/n) " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres && \
		sudo rm -rf out/pgdata; \
		echo "Файлы volumes удалены."; \
	else \
		echo "Очистка volumes отменена."; \
	fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Ошибка: переменная seq не установлена. Используйте make migrate-create seq=<номер>."; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Ошибка: переменная action не установлена. Используйте make migrate-action action=<up|down>."; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable&search_path=public" \
		"$(action)"
migrate-force:
	@if [ -z "$(v)" ]; then \
		echo "Ошибка: переменная v не установлена. Используйте make migrate-force v=<версия>."; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable&search_path=public" \
		force "$(v)"

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder