{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "web.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 21 chars because Kubernetes name fields are limited to 24 (by the DNS naming spec)
and Statefulset will append -xx at the end of name.
*/}}
{{- define "web.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 -}}
{{- end -}}

{{/*
Generate a domain of service
*/}}
{{- define "web.domain" -}}
{{- printf "%s.%s" .Release.Name .Values.config.domain | trunc 63 -}}
{{- end -}}
