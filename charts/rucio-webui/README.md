# Rucio

##  Data Management for science in the Big Data era.

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## QuickStart

Add the Rucio Helm repository to your local Helm installation:
```bash
helm repo add rucio https://rucio.github.io/helm-charts
```

## Introduction

This chart bootstraps a Rucio WebUI deployment and service on a Kubernetes cluster using the Helm Package manager.

Rucio WebUI is a [NextJS](https://nextjs.org/) application that provides a web interface to interact with the Rucio server. The application is packaged via PM2 and served using Apache.

## Configuration
The default configuration values for this chart are listed in `values.yaml` our you can get them with:

```bash
helm inspect values rucio/rucio-webui
```

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` as shown before.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
helm install \
    --name my-release \
    -f values.yaml \
    rucio/rucio-webui
```
### Basic Configuration
At the bare minimum, you will need to provide the following parameters:
`config.webui.rucio_host` - The hostname of the Rucio server to connect to.
`config.webui.rucio_auth_host` - The hostname of the Rucio authentication server to connect to.
`config.webui.hostname` - The hostname of the WebUI server.
`config.webui.project_url`- The public URL of your collaboration's project page.

### VO Configuration
To configure multiple vo's, you can use the `config.webui.vo` parameter. This parameter is a csv string of the short names of the vo's you want to configure. For example, to configure the `atlas` and `cms` vo's, you would set `config.webui.vo` to `atl,cms`.

For each VO, you will have to provide parameters in the `config.vo` section. For example,
```yaml
config:
  vo:
    atl:
      name: ATLAS
      oidc_enabled: "False"
      oidc_providers: ""
    cms:
      name: CMS
      oidc_enabled: "False"
      oidc_providers: ""
```

## Service, TLS Termination and Certificates
By default, the WebUI pods will listen on port 80 using plain HTTP and the default services are of type `ClusterIP` on port 80. To run the pods with https you will first have to install the necessary hostcert, hostkey and ca-bundles.

The host certificates and CA bundle must be created before the pod start. The certificates and CA bundle must be provided as secrets in the same namespace as the WebUI pod. The secret names must be prepended with the same `Release.Name` of the chart. The secret must contain the following:

### CA Bundle
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {.Release.Name}-cafile
  namespace: {your_namespace}
data:
    ca.pem: {base64 encoded ca.pem}
type: Opaque
```
### Hostcert
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {.Release.Name}-hostcert
  namespace: {your_namespace}
data:
    hostcert.pem: {base64 encoded hostcert.pem}
type: Opaque
```

### Hostkey
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {.Release.Name}-hostkey
  namespace: {your_namespace}
data:
    hostkey.pem: {base64 encoded hostkey.pem}
type: Opaque
```
### Generate Secrets
You can generate the secrets using the following commands:
```bash
kubectl create secret generic <releasename>-server-hostcert --from-file=hostcert.pem=/path/to/hostcert.pem   
kubectl create secret generic <releasename>-server-hostkey --from-file=hostkey.pem=/path/to/hostkey.pem
kubectl create secret generic <releasename>-server-cafile --from-file=ca.pem=/path/to/ca.pem
```
### Enable HTTPS
To enable HTTPS, you will have to set the `config.webui.useSSL` parameter to `true`. You will also have to adapt the service to port 443:
```yaml
service:
  type: ClusterIP
  port: 443
  targetPort: 443
  protocol: TCP
  name: https
```

Furthermore, you can also change the service type depending on how you want to expose the WebUI. For example, to expose the WebUI using a `LoadBalancer` service, you would set the `service.type` parameter to `LoadBalancer`. To expose the WebUI using a `NodePort` service, you would set the `service.type` parameter to `NodePort` and the `service.nodePort` parameter to the desired port.

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

You will have to install the valid certificate and key as a secret in the 
cluster that you can then configure in the ingress definition:
```bash
kubectl create secret tls rucio-webui.tls-secret --key=tls.key --cert=tls.crt
```
```yaml
    ingress:
      enabled: true
      path: /
      hosts:
        - my.rucio.test
      tls:
        - secretName: rucio-server.tls-secret
```

## Additional Configuration
The webui container can be fully configured by providing the environment variables listed [here](https://github.com/rucio/containers/tree/master/webui#configuration). You can specify the `Full Name` of the variable in the `optionalConfig` section of the `values.yaml` file. Please note that the `Full Name` implies the `RUCIO_WEBUI_` prefix or the `RUCIO_HTTPD_` or the `RUCIO_` prefix, depending the on configuration group.

## Logs
The `config.logs.exposeHttpdLogs` parameter will start a sidecar container that will expose the logs of the Apache server. The logs will be available at the `/var/log/httpd` directory of the container and can also be accessed as `stdout` of the busybox container.

The `config.logs.exposeWebuiLogs` parameter will start a sidecar container that will expose the logs of the WebUI application. The logs will be available at the `/var/log/webui` directory of the container and can also be accessed as `stdout` of the busybox container.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

    $ helm delete my-release --purge

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Getting Support

If you are looking for support, please contact us via one of our [official channels](https://rucio.cern.ch/documentation/contact_us/).