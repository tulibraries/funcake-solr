# Funnel Cake (funcake) Solr Configurations

These are the Solr configuration files for the Funnel Cake (PA Digital) internal metadata search & faceting Solr collection.

## Prerequisites

- These configurations are built for Solr 8.1
- The instructions below presume a SolrCloud multi-node setup (using an external Zookeeper)

## Local Testing / Development

You need a local SolrCloud cluster running to load these into. For example, use the make commands + docker-compose file in https://github.com/tulibraries/ansible-playbook-solrcloud to start a cluster. That repository's makefile includes this set of configurations and collection (funcake) in its `make create-release-collections` and `make create-aliases` commands.

If you want to go through those steps yourself, once you have a working SolrCloud cluster:

1. clone this repository locally & change into the top level directory of the repository

```
$ git clone https://github.com/tulibraries/funcake-solr.git
$ cd funcake-solr
```

2. zip the contents of this repository *without* the top-level directory

```
$ zip -r - * > funcake.zip
```

3. load the configs zip file into a new SolrCloud ConfigSet (change the solr url to whichever solr you're developing against)

```
$ curl -X POST --header "Content-Type:application/octet-stream" --data-binary @funcake.zip "http://localhost:8081/solr/admin/configs?action=UPLOAD&name=funcake"
```

4. create a new SolrCloud Collection using that ConfigSet (change the solr url to whichever solr you're developing against)

```
$ curl "http://localhost:8081/solr/admin/collections?action=CREATE&name=funcake-v0.1&numShards=1&replicationFactor=3&maxShardsPerNode=1&collection.configName=funcake"
```

5. create a new SolrCloud Alias pointing to that Collection (if you want to use an Alias; and change the solr url to whatever solr you're developing against):

```
$ curl "http://localhost:8081/solr/admin/collections?action=CREATEALIAS&name=funcake-dev&collections=funcake"
```

## SolrCloud Deployment

### Stage

All PRs merged into the `master` branch get deployed to SolrCloud Stage, a place to confirm the configurations work at an infrastructure & development level. The ConfigSet & Collection are named for the _expected_ next release number. *This is not where primary UAT or QA of the data and presentation of the Solr Collection using the updated Configs live. That is the production solrcloud release, below*. Upon being merged to `master`, the following occurs:
1. new ConfigSet of `funcake-v{latest+1}` is created in [Stage SolrCloud](https://solrcloud.stage.tul-infra.page);
2. new Collection of `funcake-v{latest+1}` is created in [Stage SolrCloud](https://solrcloud.stage.tul-infra.page) w/the requisite ConfigSet;
3. the existing alias of `funcake` is updated to point at the new `funcake-v{latest+1}` collection;
4. and, manually, any test indexing (_if desired_) is kicked off from Airflow Stage to this `funcake` alias.

After some time (1-4 days, as needed), the older funcake collections are removed from Stage SolrCloud.

### Production

Once a new set of configs are merged to `master` branch, deployed to Stage, and adequately reviewed, a release is cut. Upon creating the release (`v{latest+1}`), the following occurs:
1. new ConfigSet of `funcake-v{latest+1}` is created in [Production SolrCloud](https://solrcloud.tul-infra.page);
2. new Collection of `funcake-v{latest+1}` is created in [Production SolrCloud](https://solrcloud.tul-infra.page) w/the requisite ConfigSet;
3. a new dev alias of `funcake-v{latest+1}-dev` is created in [Production SolrCloud](https://solrcloud.tul-infra.page), pointing to the requisite Collection;
4. and, manually, a full reindex DAG is kicked off from Airflow Production to this new funcake dev alias. Upon completion of the reindex, dev clients are redeployed pointing at this new alias, and *then QA & UAT review occur*.
5. After QA review, the Production alias of `funcake-v{latest+1}-prod` is created manually, and the alias is pointed to the `funcake-v{latest+1}` collection just reviewed in dev. Prod Client apps are updated to point at this new alias and re-deployed.

After some time (1-4 days, as needed), the older funcake collections are removed from Prod SolrCloud.
