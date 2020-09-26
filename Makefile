build:
	go build

deploy:
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
