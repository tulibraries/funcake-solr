#!/usr/bin/env bash
set -e
validate_status() {
  echo "response: $RESP"
  STATUS=$(echo "$RESP" | grep HTTP | awk '{print $2}')
  if [[  "$STATUS" != "200" ]]; then
    echo "Failing because status was not 200"
    echo "status: $STATUS"
    exit 1
  fi
}
echo
echo "***"
echo "* Sending funcake-$CIRCLE_TAG configs to SolrCloud."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/circleci/solrconfig.zip "https://solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=funcake-$CIRCLE_TAG")
validate_status
echo
echo "***"
echo "* Creating new funcake-$CIRCLE_TAG collection"
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X GET --header 'Accept: application/json' "https://solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=funcake-$CIRCLE_TAG-init&numShards=1&replicationFactor=2&maxShardsPerNode=1&collection.configName=funcake-$CIRCLE_TAG")
validate_status
echo
echo "***"
echo "* Creating dev alias based on configset name."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" "https://solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=funcake-$CIRCLE_TAG-dev&collections=funcake-$CIRCLE_TAG-init")
validate_status
echo "***"
echo "* Creating prod alias based on configset name."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" "https://solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=funcake-$CIRCLE_TAG-prod&collections=funcake-$CIRCLE_TAG-init")
validate_status
echo "***"
echo "* Pushing zip file asset to GitHub release."
echo "***"
curl -v -X POST -H "Authorization: token $GITHUB_TOKEN" --data-binary @"/home/circleci/solrconfig.zip" -H "Content-Type: application/octet-stream" "https://uploads.github.com/repos/tulibraries/funcake-solr/releases/$CIRCLE_TAG/assets?name=funcake-$CIRCLE_TAG.zip"
