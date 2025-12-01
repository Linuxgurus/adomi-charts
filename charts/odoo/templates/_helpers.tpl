
{{/* Return the database secret name */}}
{{- define "fullname" -}}
{{- printf "%s-%s" $.Release.Name $.Chart.Name -}}
{{- end -}}
