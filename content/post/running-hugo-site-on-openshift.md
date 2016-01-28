+++
date = "2016-01-27T20:02:01-08:00"
draft = false
title = "Running hugo on Openshift"
tags = ["go","openshift"]
topics = ["Linux"]
type = "post"
+++
# Running Hugo on Openshift #

I moved my blog/site from [Ghost](http://ghost.org) to [hugo](http://gohugo.io). Since Ghost is a Nodejs app, it was easy to deploy in Openshift. But hugo, a static site generator was not. I looked at hacking up the Jekyll cartridge, but in the end decided to build my own. Maybe I'll convert this into a cartridge at some point. This isn't really mean to be a script. Mostly a recipe for you to follow along. It's not annotated; there's nothing particularly cryptic going on here.

```
rhc app-create $NAME diy
git rm *
git commit -m "Remove DIY stuff"
hugo new site .
echo "/public" > .gitignore
mkdir bin
cp ~/bin/hugo bin/
git add *
git commit -m "Adding hugo site"
cat << EOF > .openshift/action_hooks/build
#!/bin/bash

rm -rf $OPENSHIFT_REPO_DIR/public
EOF
chmod 755 .openshift/action_hooks/build
cat << EOF > .openshift/action_hooks/start
#!/bin/bash
# The logic to start up your application should be put in this
# script. The application will work only if it binds to
# $OPENSHIFT_DIY_IP:$OPENSHIFT_DIY_PORT
nohup $OPENSHIFT_REPO_DIR/bin/hugo \
	--bind=$OPENSHIFT_DIY_IP \
	--port=$OPENSHIFT_DIY_PORT \
	--source=$OPENSHIFT_REPO_DIR \
	--destination=$OPENSHIFT_REPO_DIR/public \
	--watch=false \
	--appendPort=false \
	--disableLiveReload=true \
	--baseURL="http://my-base-url/" \
	server |& /usr/bin/logshifter -tag diy &
EOF
cat << EOF > .openshift/action_hooks/stop
#!/bin/bash
source $OPENSHIFT_CARTRIDGE_SDK_BASH

# The logic to stop your application should be put in this script.
if [ -z "$(ps -ef | grep hugo | grep -v grep)" ]
then
    client_result "Application is already stopped"
else
    kill `ps -ef | grep hugo | grep -v grep | awk '{ print $2 }'` > /dev/null 2>&1
fi
EOF
git add .openshift/action_hooks/*
git commit -m "updating action_hooks"
git push
```
