#!/bin/bash
set -e

LATEST_TAG=$(curl -s https://api.github.com/repos/tulibraries/funcake-solr/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
NEW_TAG=$(($LATEST_TAG + 1))
echo $NEW_TAG
curl -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/funcake.zip "https://$SOLR_STAGE_USER:$SOLR_STAGE_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=funcake-$NEW_TAG"
curl "https://$SOLR_STAGE_USER:$SOLR_STAGE_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=funcake-$NEW_TAG&numShards=1&replicationFactor=3&maxShardsPerNode=1&collection.configName=funcake-$NEW_TAG"
curl "https://$SOLR_STAGE_USER:$SOLR_STAGE_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=funcake-$NEW_TAG-qa&collections=funcake-$NEW_TAG"
