#!/usr/bin/env bash
set -e
cd ..
git clone --single-branch --branch master git@github.com:tulibraries/ansible-playbook-solrcloud.git
mkdir -p ansible-playbook-solrcloud/data/tmp/collections
cp -r ~/project ansible-playbook-solrcloud/data/tmp/collections/funcake
cd ansible-playbook-solrcloud
make build
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8090/solr)
while [[ "$STATUS" != "302" ]]; do
  echo waiting for setup to complete or equal 302.
  echo "currently: $STATUS"
  sleep 2
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8090/solr)
done
make create-local-collections
make create-aliases
