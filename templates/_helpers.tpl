{{- /* merged helpers from app and postgres charts */ -}}

{{- define "fullname" -}}
{{- printf "%s-%s" $.Release.Name $.Chart.Name -}}
{{- end -}}

{{- /* component-specific fullname helpers */ -}}
{{- define "fullname_app" -}}
{{- printf "%s-%s-%s" $.Release.Name $.Chart.Name "app" -}}
{{- end -}}

{{- define "fullname_postgres" -}}
{{- printf "%s-%s-%s" $.Release.Name $.Chart.Name "postgres" -}}
{{- end -}}

{{/* Postgres-specific helpers */}}
{{- define "randomPassword" -}}
{{- randAlphaNum 16 -}}
{{- end -}}

{{- define "secretName" -}}
{{- $.Values.secret.existingSecret | default $.Values.secret.name | default (printf "%s-%s" .Release.Name "postgres") -}}
{{- end -}}

{{/*
Common labels and annotations helpers from app chart.

Usage in templates:
  labels:
    {{- include "commonLabels" . | nindent 4 }}
    {{- with .Values.labels }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
*/}}

{{- define "commonLabels" -}}
app.kubernetes.io/name: {{ include "fullname" . }}
app.kubernetes.io/instance: {{ $.Release.Name }}
app.kubernetes.io/version: {{ $.Chart.AppVersion | default $.Chart.Version }}
app.kubernetes.io/managed-by: {{ $.Release.Service }}
{{- end }}

{{- define "commonAnnotations" -}}
{{- if $.Values.annotations }}
{{ toYaml $.Values.annotations | nindent 0 }}
{{- else -}}
{{- end }}
{{- end }}

{{- define "mergeLabels" -}}
{{- $common := dict "app.kubernetes.io/name" (include "fullname" .) -}}
{{- $common = merge $common (dict "app.kubernetes.io/instance" $.Release.Name) -}}
{{- $common = merge $common (dict "app.kubernetes.io/version" ($.Chart.AppVersion | default $.Chart.Version)) -}}
{{- $common = merge $common (dict "app.kubernetes.io/managed-by" $.Release.Service) -}}
{{- /* add component-specific app label so Services can select by 'app' */ -}}
{{- if eq $.Chart.Name "postgres" }}
{{- $common = merge $common (dict "app" (include "fullname_postgres" .)) -}}
{{- else }}
{{- $common = merge $common (dict "app" (include "fullname_app" .)) -}}
{{- end }}
{{- if $.Values.labels }}
{{- $merged := merge $common $.Values.labels }}
{{- toYaml $merged | nindent 0 }}
{{- else -}}
{{- toYaml $common | nindent 0 }}
{{- end -}}
{{- end }}

{{- define "mergePodLabels" -}}
{{- if $.Values.podLabels }}
{{- $merged := merge (fromYaml (include "mergeLabels" .)) $.Values.podLabels }}
{{- toYaml $merged | nindent 0 }}
{{- else -}}
{{- include "mergeLabels" . -}}
{{- end -}}
{{- end }}

{{- define "mergeAnnotations" -}}
{{- if $.Values.annotations }}
{{- toYaml $.Values.annotations | nindent 0 }}
{{- else -}}
{{- /* empty */ -}}
{{- end }}
{{- end }}

{{- define "mergePodAnnotations" -}}
{{- if $.Values.podAnnotations }}
{{- toYaml $.Values.podAnnotations | nindent 0 }}
{{- else -}}
{{- include "mergeAnnotations" . -}}
{{- end -}}
{{- end }}

