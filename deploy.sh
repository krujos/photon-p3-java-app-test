#!/bin/bash -x

if [[ -z ${ENV_NUM} ]] ; then 
	>&2 echo "ENV_NUM must be set!"
fi

git clone https://github.com/pivotal-customer0/p1-photon-setup-scripts
source p1-photon-setup-scripts/env${ENV_NUM}.sh
rm -rf p1-photon-setup-scripts
for v in $CF_API $CF_USERNAME $CF_PASSWORD $CF_APPS_DOMAIN; do
	if [[ -z $v ]] ; then
		>&2 echo "$v must be set!"
	fi
done

cf api $CF_API --skip-ssl-validation
cf auth $CF_USERNAME $CF_PASSWORD
cf create-org javatests
cf create-space tests -o javatests
cf target -o javatests -s tests

git clone https://github.com/pivotal-customer0/hello-java

cd hello-java
cf push hello-java -p target/demo-0.0.1-SNAPSHOT.jar
if [[ $? != 0 ]]; then
	>&2 echo "Failed to push hello-java to $CF_API"
	exit 1
fi

curl hello-java.$CF_APPS_DOMAIN | grep "Hello world"
if [[ $? != 0 ]]; then
	>&2 echo "Failed find hello-java at hello-java.$CF_APPS_DOMAIN"
	exit 1
fi

curl hello-java.$CF_APPS_DOMAIN/kill
sleep 60
curl hello-java.$CF_APPS_DOMAIN | grep "Hello world"

if [[ $? != 0 ]]; then
	>&2 echo "Failed find hello-java at hello-java.$CF_APPS_DOMAIN after killing it."
	exit 1
fi


cf delete-org javatests -f
cd ..
rm -rf hello-java
