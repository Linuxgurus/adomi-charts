{{/* Return the database secret name */}}
{{- define "fullname" -}}
{{ printf "%s-%s" .Release.Name .Chart.Name}}
{{- end -}}

{{/* Return the PostgreSQL password, generating a random one if not provided */}}
{{ define "randomPassword" }}
{{- randAlphaNum 16 -}}
{{ end }}

{{/* The name of the secret that we use */}}
{{- define  "secretName" -}}
{{ .Values.secret.existingSecret | default .Values.secret.name | default (include "fullname" .) }}
{{- end -}}

