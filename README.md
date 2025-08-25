[![Release Charts](https://github.com/rucio/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/rucio/helm-charts/actions/workflows/release.yml) [![Lint and Test Charts](https://github.com/rucio/helm-charts/actions/workflows/lint-test.yml/badge.svg)](https://github.com/rucio/helm-charts/actions/workflows/lint-test.yml)

# Rucio Helm Charts 

##  Data Management for science in the Big Data era.

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. 
The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. 
Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. 
Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## Development Environment
 
This repository provides [development container configuration for IDEs supporting dev containers to test Helm charts with Kind](./.devcontainer/kind/devcontainer.json). The setup includes Kind cluster with kubectl/Helm and chart-testing tools for validation.

## Helm Charts

This repository contains Helm Charts for the major different components of Rucio (https://rucio.cern.ch), the Rucio server, daemons, probes, and the Rucio WebUI.
Helm (https://helm.sh) helps you manage Kubernetes applications. 
Helm Charts help you define, install, and upgrade  Kubernetes applications. 
Further, Helm Charts can be combined with Flux (https://fluxcd.io) to fully implement GitOps. 
Just push to Git and Flux does the rest.

### Installation example

Add the Rucio Helm repository to your local Helm installation then you can install the Rucio server like so.


    $ helm repo add rucio https://rucio.github.io/helm-charts
    $ helm install rucio/rucio-server

## Chart Versioning

The latest chart version is always recommended for use with the latest Rucio version. 
The Rucio Helm Chart versions are correlated with Rucio versions at the major verion level; each product follows it's own patch versioning.
I. e., Helm Chart 34.0.3 contains Helm improvements over chart 34.0.2 and both are compatible with any Rucio 34.Y.Z release.

Developers: Please make pull requests for charts for the current Rucio version against the `main` or `master` branch. 
Fixes which are relevant to previous versions may also have pull requests made against the relevant release-X (e.g. release-34) branch.
Patches against old, non-LTS Rucio releases will be accepted, but no effort will be made to make sure all fixes are made.
For LTS releases (currently 1.29 and 32), the charts for those releases should be kept up to date.

For details on installing a particular chart, see the README.md in that portion of this repository.

## Getting Support

If you are looking for support, please contact us via one of our [official channels](https://rucio.cern.ch/documentation/contact_us/).
