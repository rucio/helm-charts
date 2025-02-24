{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rucio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rucio.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rucio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get Ingress Kube API Version
*/}}
{{- define "rucio.kubeApiVersion.ingress" -}}
  {{- if semverCompare ">= 1.19.x" (default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride) -}}
    {{- print "networking.k8s.io/v1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Get CronJob Kube API Version
*/}}
{{- define "rucio.kubeApiVersion.cronjob" -}}
  {{- if semverCompare ">= 1.22.x" (default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride) -}}
    {{- print "batch/v1" -}}
  {{- else -}}
    {{- print "batch/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Image Registry
Ensures the registry ends with a `/` if set.
*/}}
{{- define "rucio.image.registry" -}}
  {{- if .Values.imageRegistry -}}
    {{- trimSuffix "/" .Values.imageRegistry }}/
  {{- end -}}
{{- end -}}
