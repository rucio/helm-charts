# Rucio

##  Data Management for science in the Big Data era.

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## QuickStart

Add the Rucio Helm repository to your local Helm installation and install it using:

    $ helm repo add rucio https://rucio.github.io/helm-charts
    $ helm install rucio/rucio-ui

## Introduction

This chart bootstraps a Rucio WebUI deployment and service on a Kubernetes cluster using the Helm Package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

    $ helm install \
      --name my-release \
      rucio/rucio-ui

The command deploys a Rucio webui server on the Kubernetes cluster in the default configuration, i.e., 1 replicas using an un-initialised SQLite database without an ingress. To fully use this chart an already bootstraped database together with a deployed rucio server and authentication server which have to configurated using the `proxy.rucioProxy` and `rucio.rucioAuthProxy` config variables.

To install the chart so that is will connected to a MySQL DB running at `mysql.db` with the user `rucio` and password `rucio` and a rucio server running at `my.rucio.server` and a auth server at `my.auth.server`.

    $ helm install \
      --name my-release \
      --set config.database.default="mysql://rucio:rucio@mysql.db/rucio" \
      --set proxy.rucioProxy="my.rucio.server" \
      --set proxy.rucioAuthProxy="my.auth.server" \
      rucio/rucio-ui

## Configuration

The default configuration values for this chart are listed in `values.yaml` our you can get them with:

    $ helm inspect values rucio/rucio-ui

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` as shown before.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

    $ helm install \
      --name my-release \
      -f values.yaml \
      rucio/rucio-ui

## Service

The service type and port can be configured in `values.yaml` like this:

    service:
      type: NodePort
      useSSL: true
      port: 443
      targetPort: https
      portName: https

By default the WebUI uses HTTPS and expects the host certificate, key and CA file to be installed as secrets in the cluster: `<releasename>-hostcert`, `<releasename>-hostkey` and `<releasename>-cafile`. If only userpass authentication is used the service can also be changed to use plain HTTP (not advised). But the secrets still have to be installed in the cluster for the pods to start.

## Ingress

If you want to use X509 user certificate authentication in the WebUI an ingress controller with TLS passthrough support is needed. This documentation will focus on the nginx ingress controller.

    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
        nginx.ingress.kubernetes.io/ssl-passthrough: "true"
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
      hosts:
        - my.rucio-webui.test
      path: /

## Proxy

The WebUI uses a local proxy to forward the requests to the api and authentication servers. They have to be configured in `values.yaml` for the WebUI to work:

    proxy:
      rucioProxy: "my.rucio.test"
      rucioProxyScheme: "https"
      rucioAuthProxy: "my.rucio-auth.test"
      rucioAuthProxyScheme: "https"

## httpd config

The `httpd_config` can be used to configure the mpm mode. The default mpm mode is `event` and default configuration parameters can be found in `values.yaml`. More details are available in the Apache [documentation](http://httpd.apache.org/docs/current/mpm.html).

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

    $ helm delete my-release --purge

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Getting Support

If you are looking for support, please contact our mailing list rucio-users@googlegroups.com
or join us on our [slack support](<https://rucio.slack.com/messages/#support>) channel.
