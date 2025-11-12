# Makefile

.DEFAULT_GOAL := help

#=====================
# 基本タスク
#=====================

init: ## 初期セットアップ（build, bundle, db作成, migrate, up）
	@echo ">>> Docker build..."
	docker compose build

	@echo ">>> Bundle install..."
	docker compose run --rm app bundle install

	@echo ">>> DB create & migrate..."
	docker compose run --rm app bin/rails db:create
	docker compose run --rm app bin/rails db:migrate

	@echo ">>> Initialize tapioca..."
	docker compose run --rm app bundle exec tapioca init
	docker compose run --rm app bundle exec tapioca gems
	docker compose run --rm app bundle exec tapioca dsl

	@echo ">>> Starting containers..."
	docker compose up -d

build: ## Docker イメージをビルド
	docker compose build

up: ## コンテナを起動（バックグラウンド）
	docker compose up -d

down: ## コンテナを停止・削除
	docker compose down

logs: ## アプリのログをフォロー
	docker compose logs -f app

ps: ## コンテナの状態を表示
	docker compose ps

bundle: ## bundle install
	docker compose run --rm app bundle install

bash: ## app コンテナに bash で入る
	docker compose exec app bash

#=====================
# DB 操作
#=====================

db-create: ## DB作成
	docker compose run --rm app bin/rails db:create

db-migrate: ## マイグレーション実行
	docker compose run --rm app bin/rails db:migrate

db-drop: ## DB削除
	docker compose run --rm app bin/rails db:drop

db-seed: ## seed投入
	docker compose run --rm app bin/rails db:seed

reset: ## DBをdrop→create→migrate→seedまで
	@echo ">>> Reset database..."
	docker compose run --rm app bin/rails db:drop
	docker compose run --rm app bin/rails db:create
	docker compose run --rm app bin/rails db:migrate
	docker compose run --rm app bin/rails db:seed

#=====================
# Rails ツール
#=====================

console: ## Rails コンソールを開く
	docker compose exec app bin/rails c

#=====================
# ヘルプ
#=====================

help: ## このヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
