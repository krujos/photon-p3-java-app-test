#!env bash
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
cf push hello-java
if [ $? != 0 ]; then
	>&2 echo "Failed to push hello-java to $CF_API"
	exit 1
fi

curl hello-java.$CF_APPS_DOMAIN
	if [[ $? != 0 ]]; then
	>&2 echo "Failed find hello-java at hello-java.$CF_APPS_DOMAIN"
	exit 1
fi


cf delete-org javatests -f
cd ..
rm -rf hello-java
