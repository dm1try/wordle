.PHONY: help build up down logs test clean seed-dict

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	docker compose build

up: ## Start development environment
	docker compose up

up-d: ## Start development environment in background
	docker compose up -d

down: ## Stop and remove containers
	docker compose down

logs: ## View logs from all services
	docker compose logs -f

logs-app: ## View logs from app service only
	docker compose logs -f app

test: ## Run tests
	docker compose run --rm app bash -c "APP_ENV=test REDIS_URL=redis://redis:6379/2 bundle exec ruby setup/prepare_test_db.rb && bundle exec rspec"

shell: ## Access app container shell
	docker compose exec app bash

redis-cli: ## Access Redis CLI
	docker compose exec redis redis-cli

clean: ## Remove containers, volumes and images
	docker compose down -v
	docker rmi wordle-app 2>/dev/null || true

prod-up: ## Start production environment
	docker compose -f docker-compose.prod.yml up -d --build

prod-down: ## Stop production environment
	docker compose -f docker-compose.prod.yml down

prod-logs: ## View production logs
	docker compose -f docker-compose.prod.yml logs -f
