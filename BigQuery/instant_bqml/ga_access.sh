#!/bin/bash -ex

curl -v --location --request POST 'https://instant-bqml.appspot.com/qwiklabs' \
	--header 'application/x-www-form-urlencoded' \
	--data-raw 'username=binwu%40google.com'
