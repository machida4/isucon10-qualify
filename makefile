.DEFAULT_GOAL := help

restart: ## copy configs from repository to conf
	@git pull
	@sudo cp config/nginx.conf /etc/nginx/
	@sudo cp config/my.cnf /etc/mysql/
	@make -s nginx-restart
	@make -s db-restart
	@make -s ruby-restart

ruby-restart: ## Restart Server
	@sudo systemctl daemon-reload
	@bundle 1> /dev/null
	@sudo systemctl restart isuumo.ruby.service
	@echo 'Restart ruby'

ruby-log: ## log Server
	@sudo journalctl -f -u isuumo.ruby.service

nginx-restart: ## Restart nginx
	@sudo systemctl restart nginx
	@echo 'Restart nginx'

nginx-log: ## tail nginx access.log
	@sudo tail -f /var/log/nginx/access.log

nginx-error-log: ## tail nginx error.log
	@sudo tail -f /var/log/nginx/error.log

alp: ## Run alp
	@alp -f /var/log/nginx/access.log  --sum  -r --aggregates '/profile/\w+, /diary/entry/\d+, /diary/entries/\w+, /diary/comment/\d+, /friends/\w+' --start-time-duration 5m

db-restart: ## Restart mysql
	@sudo systemctl restart mysql
	@echo 'Restart mysql'

db-log: ## tail mysql.log
	@sudo tail -f /var/log/mysql/mysql.log

db-analyze: ## analyze mysql-slow.log
	@sudo pt-query-digest /var/lib/mysql/mysql-slow.log

.PHONY: help
help:
    @grep -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'