
server:
	hugo server

build:
	hugo

publish:
	cd public && rsync -avr --rsh=ssh * dh_7yy6kj@tricia-mcmillan.dreamhost.com:~/sub-pop.net/