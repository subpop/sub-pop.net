
server:
	hugo server

build:
	hugo

publish:
	cd public && rsync -avr --delete-after --rsh=ssh * root@185.101.97.150:/data/www/sub-pop.net/
