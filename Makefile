build:
	go build

deploy:
	go build
	ssh isucon8final-a sudo mv /var/log/nginx/access.log /var/log/nginx/access.log-`date +%Y%m%d-%H%M%S` || true
	ssh isucon8final-a sudo systemctl restart nginx
	ssh isucon8final-a sudo chmod 644 /var/log/nginx/access.log || true
	ssh isucon8final-a sudo systemctl stop isucoin
	scp start.sh isucon8final-a:/home/isucon/isucon8-final/webapp/start.sh
	scp isucon8 isucon8final-a:/home/isucon/isucon8-final/webapp/isucoin
	ssh isucon8final-a sudo systemctl start isucoin

service-deploy:
	ssh isucon8final-a sudo tee /etc/systemd/system/isucoin.service < isucoin.service
	ssh isucon8final-a sudo systemctl daemon-reload

nginx-deploy:
	ssh isucon8final-a sudo tee /etc/nginx/nginx.conf < nginx.conf
	ssh isucon8final-a sudo systemctl restart nginx
	
mysql-deploy:
	ssh isucon8final-b sudo tee /etc/mysql/my.cnf < my.cnf
	ssh isucon8final-b sudo systemctl restart mysql

import_logs:
	sh import_logs.sh

pprof:
	go tool pprof -http=127.0.0.1:8020 logs/latest/cpu.pprof
