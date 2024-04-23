# Rucio

##  Data Management for science in the Big Data era.

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## QuickStart

Add the Rucio Helm repository to your local Helm installation and install it using:


    $ helm repo add rucio https://rucio.github.io/helm-charts
    $ helm install rucio/rucio-server

## Introduction

This chart bootstraps a Rucio server deployment and service on a Kubernetes cluster using the Helm Package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

    $ helm install \
      --name my-release \
      rucio/rucio-server

The command deploys a Rucio server on the Kubernetes cluster in the default configuration, i.e., 2 replicas using an un-initialised SQLite database without an ingress. To fully use this chart an already bootstraped database is necessary. The server can then be configured to use the DB.

To install the chart so that is will connected to a MySQL DB running at `mysql.db` with the user `rucio` and password `rucio`:

    $ helm install \
      --name my-release \
      --set config.database.default="mysql://rucio:rucio@mysql.db/rucio" \
      rucio/rucio-server

## Configuration

The default configuration values for this chart are listed in `values.yaml` our you can get them with:

    $ helm inspect values rucio/rucio-server

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` as shown before.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

    $ helm install \
      --name my-release \
      -f values.yaml \
      rucio/rucio-server


## Certificates

Some functions require certificates and CAs to work. They expect specific secrets that need to be created before the pod can start.

### API calls to FTS

To update rule priority in FTS, the API call must be authenticated. The
configuration is identical to the one of the 
[conveyor](https://github.com/rucio/helm-charts/tree/master/charts/rucio-daemons#conveyor) 
daemon. 

## Service

By default the servers pods are listening on port 80 using plain HTTP and the 
default services are of type `ClusterIP` on port 80. To run the pods with HTTPS
you will first have to install the necessary key, cert and CA files for the 
corresponding servers:

First create the secrets:

    kubectl create secret generic <releasename>-server-hostcert --from-file=hostcert.pem=/path/to/hostcert.pem   
    kubectl create secret generic <releasename>-server-hostkey --from-file=hostkey.pem=/path/to/hostkey.pem
    kubectl create secret generic <releasename>-server-cafile --from-file=ca.pem=/path/to/ca.pem

Then you can use a switch in the config file to enable HTTPS per server type:

    useSSL: true

You will then have to adapt the service to port 443:

    service:
      type: ClusterIP
      port: 443
      targetPort: 443
      protocol: TCP
      name: https

Furthermore, you can also change the service type depending on how you want to 
expose your service outside of the cluster. If you don't use an ingress
controller you can also set it to `NodePort` or `LoadBalancer` (if available).

## Ingress

If you want to use and ingress controller to expose the servers you will have to
configure them separately. In this case the service type should stay as 
`ClusterIP`. A simple ingress for the api server would like this:

    ingress:
      enabled: true
      path: /
      hosts:
        - my.rucio.test

In case you want to use HTTPS with an ingress you should not change the service
as explained above but instead let the ingress controller handle the TLS 
connection and then pass the requests using plain HTTP inside the cluster. 
The exception being the authentication servers that will be explained below.

You will have to install the valid certificate and key as a secret in the 
cluster that you can then configure in the ingress definition:

    $ kubectl create secret tls rucio-server.tls-secret --key=tls.key --cert=tls.crt

    ingress:
      enabled: true
      path: /
      hosts:
        - my.rucio.test
      tls:
        - secretName: rucio-server.tls-secret

## Authentication Ingress

For the authentication ingress the configuration is a bit different if you want
to use the x509 certificate authentication in Rucio. In this case the TLS
connection cannot be terminated by the ingress controller but instead it has to
be forwarded to the pods so that they can verify the user certificate. You will
need an ingress controller that supports TLS passthrough. This documentation
will focus on the nginx ingress controller.

First, the `service` has to be configured using HTTPS as described above. 
Then, you can enable passthrough in the ingress definition:

    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
        nginx.ingress.kubernetes.io/ssl-passthrough: "true"
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
      hosts:
        - my.rucio-auth.test
      path: /

## httpd config

The `httpd_config` can be used to configure the mpm mode and to enable the status page for monitoring (see below). The default mpm mode is `event` and default configuration parameters can be found in `values.yaml`. More details are available in the Apache [documentation](http://httpd.apache.org/docs/current/mpm.html).

### Additional Secrets

In case you need any additional secrets, e.g., special cloud configurations, 
license keys, etc., you can use `secretMounts` in the configuration file. You 
can install arbitrary secrets in the cluster and this config then makes it available in the pods:

    $ kubectl create secret generic my-release-rse-accounts --from-file=rse-accounts.cfg

    secretMounts: 
      - secretName: rse-accounts
        mountPath: /opt/rucio/etc/rse-accounts.cfg
        subPath: rse-accounts.cfg

This will create the file from the secret and place it at `/opt/rucio/etc/rse-accounts.cfg` in every server container.

## Automatic Restarts

In case you want to add regular restarts for your pods there a is a cronjob available that can be configured like this:

    automaticRestart:
      enabled: 1
      schedule: "15 1 * * *"

This will run according to the given schedule and do a `kubectl rollout restart deployment` for all servers.

## Prometheus Monitoring

In case you have Prometheus running in your cluster you can use the built-in exporter to let Prometheus automatically scrape your metrics:

    monitoring:
      enabled: true

Additionally, you also have to enable the status page in httpd config:

    httpd_config:
      enable_status: "True"

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

    $ helm delete my-release --purge

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Getting Support

If you are looking for support, please contact us via one of our [official channels](https://rucio.cern.ch/documentation/contact_us/).
