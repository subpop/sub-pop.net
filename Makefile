
server:
	hugo server

build:
	hugo

publish:
	cd public && rsync -avr --delete-after --rsh=ssh * root@139.177.196.239:/var/www/sub-pop.net/