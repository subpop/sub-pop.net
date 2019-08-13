
server:
	hugo server

build:
	hugo

publish:
	cd public && rsync -avr --delete-after --rsh=ssh * subpop@lynx.mythic-beasts.com:~/www/sub-pop.net/