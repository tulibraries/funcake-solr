#!/bin/bash
set -e

LATEST_TAG=$(curl -s https://api.github.com/repos/tulibraries/funcake-solr/releases/latest | jq .tag_name)
LATEST_RELEASE_ID=$(curl -s https://api.github.com/repos/tulibraries/funcake-solr/releases/latest | jq .id)
echo $LATEST_TAG
curl -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/funcake.zip "https://$SOLR_PROD_USER:$SOLR_PROD_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=funcake-$LATEST_TAG"
curl "https://$SOLR_PROD_USER:$SOLR_PROD_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=funcake-$LATEST_TAG"
curl -X POST -H "Authorization: token $CI_USER_TOKEN" --data-binary @"/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/funcake.zip" -H "Content-Type: application/octet-stream" "https://uploads.github.com/repos/tulibraries/funcake-solr/releases/$LATEST_RELEASE_ID/assets?name=funcake-$NEW_TAG.zip"
