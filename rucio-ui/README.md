# Rucio

##  Data Management for science in the Big Data era.

Rucio is a project that provides services and associated libraries for allowing scientific collaborations to manage large volumes of data spread across facilities at multiple institutions and organisations. Rucio has been developed by the `ATLAS <https://atlas.cern/>`_ experiment. It offers advanced features, is highly scalable and modular.

## QuickStart

Add the Rucio Helm repository to your local Helm installation and install it using:

```bash
$ helm repo add rucio https://rucio.github.io/helm-charts
$ helm install rucio/rucio-ui
```

## Introduction

This chart bootstraps a Rucio WebUI deployment and service on a Kubernetes cluster using the Helm Package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release rucio/rucio-ui
```

The command deploys a Rucio webui server on the Kubernetes cluster in the default configuration, i.e., 1 replicas using an un-initialised SQLite database without an ingress. To fully use this chart an already bootstraped database together with a deployed rucio server and authentication server which have to configurated using the `proxy.rucioProxy` and `rucio.rucioAuthProxy` config variables.

To install the chart so that is will connected to a MySQL DB running at `mysql.db` with the user `rucio` and password `rucio` and a rucio server running at `my.rucio.server` and a auth server at `my.auth.server`.

```bash
$ helm install --name my-release --set config.database.default="mysql://rucio:rucio@mysql.db/rucio" --set proxy.rucioProxy="my.rucio.server" --set proxy.rucioAuthProxy="my.auth.server" rucio/rucio-ui
```

## Configuration

The default configuration values for this chart are listed in `values.yaml` our you can get them with:

```bash
$ helm inspect values rucio/rucio-ui
```

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` as shown before.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml rucio/rucio-ui
```

## Ingress & Certificates

The webui server currently only work with an nginx ingress controller as it supported TLS passthrough to the backend pods. For the ingress itself only the hosts have to be configured in `values.yaml`.

For the pods to work the host certificate/key together with the CA file have to be stored as secrets in the cluster. The chart expects three secrets: `{my-release}-hostcert`,  `{my-release}-hostkey` and `{my-release}-cafile`.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.
