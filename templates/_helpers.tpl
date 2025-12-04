{{- /* Helm helpers — consolidated and safer versions */ -}}

{{- /* basic names */ -}}
{{- define "fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}

{{- define "fullname_app" -}}
{{- printf "%s-%s" (include "fullname" .) "app" -}}
{{- end -}}

{{- define "fullname_postgres" -}}
{{- printf "%s-%s" (include "fullname" .) "postgres" -}}
{{- end -}}

{{- /* random password helper for secrets (non-deterministic - used only when creating a Secret) */ -}}
{{- define "randomPassword" -}}
{{- randAlphaNum 16 -}}
{{- end -}}

{{- /* secret name resolution: prefer existingSecret, otherwise a deterministic name */ -}}
{{- define "secretName" -}}
{{- if .Values.secret.existingSecret }}
{{- .Values.secret.existingSecret -}}
{{- else -}}
{{- printf "%s-%s-postgres" .Release.Name .Chart.Name -}}
{{- end -}}
{{- end -}}

{{- /* common labels and annotations */ -}}
{{- define "commonLabels" -}}
app.kubernetes.io/name: {{ include "fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service | default "Helm" }}
{{- end -}}

{{- define "mergeLabels" -}}
{{- $common := dict "app.kubernetes.io/name" (include "fullname" .) -}}
{{- $common = merge $common (dict "app.kubernetes.io/instance" .Release.Name) -}}
{{- $common = merge $common (dict "app.kubernetes.io/version" (.Chart.AppVersion | default .Chart.Version)) -}}
{{- $common = merge $common (dict "app.kubernetes.io/managed-by" (.Release.Service | default "Helm")) -}}
{{- if .Values.labels }}
{{- $merged := merge $common .Values.labels }}
{{- toYaml $merged | nindent 0 }}
{{- else }}
{{- toYaml $common | nindent 0 }}
{{- end }}
{{- end }}

{{- define "mergePodLabels" -}}
{{- if .Values.podLabels }}
{{- $base := fromYaml (include "mergeLabels" .) }}
{{- $merged := merge $base .Values.podLabels }}
{{- toYaml $merged | nindent 0 }}
{{- else -}}
{{- include "mergeLabels" . -}}
{{- end -}}
{{- end }}

{{- define "mergeAnnotations" -}}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations | nindent 0 }}
{{- end }}
{{- end }}

{{- define "mergePodAnnotations" -}}
{{- if .Values.podAnnotations }}
{{- toYaml .Values.podAnnotations | nindent 0 }}
{{- else -}}
{{- include "mergeAnnotations" . -}}
{{- end -}}
{{- end }}

{{- /* default probes (used when user doesn't provide custom probes) */ -}}
{{- define "defaultLivenessProbe" -}}
{{- $path := "/web" -}}
{{- $port := 8069 -}}
{{- if and (hasKey .Values "app") (hasKey .Values.app "service") (hasKey .Values.app.service "ports") }}
{{- $first := index .Values.app.service.ports 0 -}}
{{- if $first.targetPort }}{{- $port = $first.targetPort }}{{- else if $first.port }}{{- $port = $first.port }}{{- end -}}
{{- end -}}
httpGet:
  path: {{ $path }}
  port: {{ $port }}
  scheme: HTTP
initialDelaySeconds: 30
periodSeconds: 10
timeoutSeconds: 5
failureThreshold: 6
{{- end }}

{{- define "defaultReadinessProbe" -}}
{{- $path := "/web" -}}
{{- $port := 8069 -}}
{{- if and (hasKey .Values "app") (hasKey .Values.app "service") (hasKey .Values.app.service "ports") }}
{{- $first := index .Values.app.service.ports 0 -}}
{{- if $first.targetPort }}{{- $port = $first.targetPort }}{{- else if $first.port }}{{- $port = $first.port }}{{- end -}}
{{- end -}}
httpGet:
  path: {{ $path }}
  port: {{ $port }}
  scheme: HTTP
initialDelaySeconds: 10
periodSeconds: 5
timeoutSeconds: 3
failureThreshold: 3
{{- end }}
