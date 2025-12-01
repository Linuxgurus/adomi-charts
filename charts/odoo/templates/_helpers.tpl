
{{/* Return the database secret name */}}
{{- define "fullname" -}}
{{- printf "%s-%s" $.Release.Name $.Chart.Name -}}
{{- end -}}

{{/*
Common labels and annotations helpers.

- `commonLabels` returns a dict of standard labels (app.kubernetes.io/*).
- `mergeLabels` will merge provided labels with the common labels (values.labels).
- `commonAnnotations` returns annotations from .Values.annotations.
- `mergePodLabels` and `mergePodAnnotations` for pod-level overrides.

Usage in templates:
  labels:
    {{- include "commonLabels" . | nindent 4 }}
    {{- with .Values.labels }}
    {{ toYaml . | nindent 4 }}
    {{- end }}

  annotations:
    {{- include "commonAnnotations" . | nindent 4 }}
    {{- with .Values.annotations }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
*/}}

{{- define "commonLabels" -}}
app.kubernetes.io/name: {{ include "fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "commonAnnotations" -}}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations | nindent 0 }}
{{- else -}}
{{- /* return empty string when no annotations are provided */ -}}
{{- end }}
{{- end }}

{{- define "mergeLabels" -}}
{{- $common := dict "app.kubernetes.io/name" (include "fullname" .) -}}
{{- $common = merge $common (dict "app.kubernetes.io/instance" .Release.Name) -}}
{{- $common = merge $common (dict "app.kubernetes.io/version" (.Chart.AppVersion | default .Chart.Version)) -}}
{{- $common = merge $common (dict "app.kubernetes.io/managed-by" .Release.Service) -}}
{{- if .Values.labels }}
{{- $merged := merge $common .Values.labels }}
{{- toYaml $merged | nindent 0 }}
{{- else -}}
{{- toYaml $common | nindent 0 }}
{{- end -}}
{{- end }}

{{- define "mergePodLabels" -}}
{{- if .Values.podLabels }}
{{- $merged := merge (fromYaml (include "mergeLabels" .)) .Values.podLabels }}
{{- toYaml $merged | nindent 0 }}
{{- else -}}
{{- include "mergeLabels" . -}}
{{- end -}}
{{- end }}

{{- define "mergeAnnotations" -}}
{{- if .Values.annotations }}
{{- toYaml .Values.annotations | nindent 0 }}
{{- else -}}
{{- /* empty */ -}}
{{- end -}}
{{- end }}

{{- define "mergePodAnnotations" -}}
{{- if .Values.podAnnotations }}
{{- toYaml .Values.podAnnotations | nindent 0 }}
{{- else -}}
{{- include "mergeAnnotations" . -}}
{{- end -}}
{{- end }}
