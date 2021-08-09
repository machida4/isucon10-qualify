.DEFAULT_GOAL := help

restart: ## copy configs from repository to conf
	@git pull
	@make -s nginx-restart
	@make -s db-restart
	@make -s app-restart

app-restart: ## Restart Server
	@sudo systemctl daemon-reload
	@bundle 1> /dev/null
	@sudo systemctl restart isuumo.ruby.service
	@echo 'Restart ruby'

app-log: ## log Server
	@sudo journalctl -f -u isuumo.ruby.service

nginx-restart: ## Restart nginx
	@sudo cp nginx.conf /etc/nginx/
	@sudo systemctl restart nginx
	@echo 'Restart nginx'

nginx-log: ## tail nginx access.log
	@sudo tail -f /var/log/nginx/access.log

nginx-error-log: ## tail nginx error.log
	@sudo tail -f /var/log/nginx/error.log

alp-dry: ## Run alp
	@sudo alp ltsv --file /var/log/nginx/access.log --sort sum --reverse --matching-groups '/api/chair/[0-9]+, /api/chair/buy/[0-9]+, /api/estate/[0-9]+, /api/estate/req_doc/[0-9]+, /api/recommended_estate/[0-9]+, /images/[a-zA-Z0-9]+.png, /_next/static/[a-zA-Z0-9]+.js'

alp: ## Run alp and post the result on discord
	@make -s alp-dry | ./dispost -f alp.txt

db-restart: ## Restart mysql
	@sudo cp my.cnf /etc/mysql/
	@sudo systemctl restart mysql
	@echo 'Restart mysql'

db-log: ## tail mysql.log
	@sudo tail -f /var/log/mysql/mysql.log

db-analyze: ## analyze mysql-slow.log
	@sudo pt-query-digest /var/log/mysql/mysql-slow.log

.PHONY: help
help:
	@grep -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'