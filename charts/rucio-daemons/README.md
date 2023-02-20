# Rucio

##  Data Management for science in the Big Data era.

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## QuickStart

Add the Rucio Helm repository to your local Helm installation and install it using:

    $ helm repo add rucio https://rucio.github.io/helm-charts
    $ helm install rucio/rucio-daemons

## Introduction

This chart bootstraps a Rucio server deployment and service on a Kubernetes cluster using the Helm Package manager.

## Installing the Chart

This chart can be used to install Rucio daemons. Not all of the possible daemons are necessary to run a instance of Rucio. Some daemons are optional. By default no daemon is activated and they have to be explicitly started. A simple daemon instance with one judge-cleaner daemon can be started like this:

    $ helm install \
      --name my-release \
      --set judgeCleanerCount=1 \
      rucio/rucio-daemons

This command will start 1 judge-cleaner using an un-initialised SQLite database. To fully use this chart an already bootstraped database is necessary. The daemons can then be configured to use the DB.

To install the chart so that is will connected to a MySQL DB running at `mysql.db` with the user `rucio` and password `rucio`:

    $ helm install \
      --name my-release \
      --set judgeCleanerCount=1 \
      --set config.database.default="mysql://rucio:rucio@mysql.db/rucio"
      rucio/rucio-daemons

## Configuration

The default configuration values for this chart are listed in `values.yaml` our you can get them with:

    $ helm inspect values rucio/rucio-daemons

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` as shown before.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

    $ helm install --name my-release -f values.yaml rucio/rucio-daemons

## Certificates

Some of the daemons require certificates and CAs to work. They expect specific secrets that need to be created before the pod can start.

### Conveyor

The conveyor needs a delegated X509 user proxy and the necessary CA so that it can submit jobs to FTS. For the CA you have to add a `<releasename>-rucio-ca-bundle` secret. For the user proxy a cronjob can be setup to either generate it from a long proxy or directly delegate the user proxy to FTS. The cronjob uses the [fts-cron](https://github.com/rucio/containers/tree/master/fts-cron) container which expects different input secrets and has a different behaviour depending on the selected VO. When enabled, the cronjob runs once upon installation and then every 6 hours. An example configuration looks like this:

    ftsRenewal:
      enabled: 1
      schedule: "12 */6 * * *"
      image:
        repository: rucio/fts-cron
        tag: latest
        pullPolicy: Always
      servers: "https://fts3-devel.cern.ch:8446,https://fts3-pilot.cern.ch:8446"
      script: default
      vos:
        - vo: "cms"
          voms: "cms:/cms/Role=production"

Please check directly the scripts in the [fts-cron](https://github.com/rucio/containers/tree/master/fts-cron)
container to see their required input. For example, the "atlas" script requires
a proxy certificate (longproxy) to be mounted into the pod at the correct
location. And it will be used to generate a short proxy into the kubernetes 
secret with the name given in the `RUCIO_FTS_SECRETS` env variable. 
The configuration will be like that:

      script: atlas
      vos:
        - vo: "atlas"
          voms: "atlas:/atlas/Role=production"
        secretMounts:
          - secretFullName: release-longproxy
            mountPath: /opt/rucio/certs/long.proxy
            subPath: long.proxy
        additionalEnvs:
          - name: RUCIO_LONG_PROXY
            value: long.proxy
          - name: RUCIO_FTS_SECRETS
            value: release-rucio-x509up


### Reaper

The reaper uses the same x509 proxy as the conveyor. So there is no additional work needed for that. But it potentially needs different CAs for all the storages it interacts with. So you have to create the `<releasename>-rucio-ca-bundle-reaper` secret for the reaper to start.

### Additional Secrets

In case you need any additional secrets, e.g., special cloud configurations, license keys, etc., you can use `additionalSecrets` in the configuration file. You can install arbitrary secrets in the cluster and this config then makes it available in the pods:

    $ kubectl create secret generic my-release-automatix-input --from-file=automatix.json

    additionalSecrets:
      automatix-input:
        secretName: automatix-input
        mountPath: /opt/rucio/etc/automatix.json
        subPath: automatix.json

This will create the file from the secret and place it at `/opt/rucio/etc/automatix.json` in every daemon container.

## Automatic Restarts

In case you want to add regular restarts for your pods there a is a cronjob available that can be configured like this:

    automaticRestart:
      enabled: 1
      image:
        repository: bitnami/kubectl
        tag: 1.18
        pullPolicy: IfNotPresent
      schedule: "15 1 * * *"

This will run according to the given schedule and do a `kubectl rollout restart deployment` for all daemons.

## Prometheus Monitoring

In case you have Prometheus running in your cluster you can use the built-in exporter to let Prometheus automatically scrape your metrics:

    monitoring:
      enabled: true
      exporterPort: 8080
      targetPort: 8080
      interval: 30s
      telemetryPath: /metrics
      namespace: monitoring
      labels:
        release: prometheus-operator

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

    $ helm delete my-release --purge

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Getting Support

If you are looking for support, please contact our mailing list rucio-users@googlegroups.com
or join us on our [slack support](<https://rucio.slack.com/messages/#support>) channel.
