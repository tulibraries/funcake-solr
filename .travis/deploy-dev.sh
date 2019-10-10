#!/bin/bash
set -e

LATEST_TAG=$(curl -s https://api.github.com/repos/tulibraries/funcake-solr/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
NEW_TAG=$(($LATEST_TAG + 1))
echo $NEW_TAG
curl -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/funcake.zip "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=funcake-$NEW_TAG-rc"
curl "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=funcake-$NEW_TAG-rc"
