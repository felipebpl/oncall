{{- define "snippet.oncall.env" -}}
- name: BASE_URL
  value: https://{{ .Values.base_url }}
- name: SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "oncall.fullname" . }}
      key: SECRET_KEY
- name: MIRAGE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "oncall.fullname" . }}
      key: MIRAGE_SECRET_KEY
- name: MIRAGE_CIPHER_IV
  value: "1234567890abcdef"
- name: DJANGO_SETTINGS_MODULE
  value: "settings.helm"
- name: AMIXR_DJANGO_ADMIN_PATH
  value: "admin"
- name: OSS
  value: "True"
- name: UWSGI_LISTEN
  value: "1024"
- name: BROKER_TYPE
  value: {{ .Values.broker.type | default "rabbitmq" }}
{{- end -}}

{{- define "snippet.oncall.slack.env" -}}
{{- if .Values.oncall.slack.enabled -}}
- name: FEATURE_SLACK_INTEGRATION_ENABLED
  value: {{ .Values.oncall.slack.enabled | toString | title | quote }}
- name: SLACK_SLASH_COMMAND_NAME
  value: "/{{ .Values.oncall.slack.commandName | default "oncall" }}"
- name: SLACK_CLIENT_OAUTH_ID
  value: {{ .Values.oncall.slack.clientId | default "" | quote }}
- name: SLACK_CLIENT_OAUTH_SECRET
  value: {{ .Values.oncall.slack.clientSecret | default "" | quote }}
- name: SLACK_SIGNING_SECRET
  value: {{ .Values.oncall.slack.signingSecret | default "" | quote }}
- name: SLACK_INSTALL_RETURN_REDIRECT_HOST
  value: {{ .Values.oncall.slack.redirectHost | default (printf "https://%s" .Values.base_url) | quote }}
{{- else -}}
- name: FEATURE_SLACK_INTEGRATION_ENABLED
  value: {{ .Values.oncall.slack.enabled | toString | title | quote }}
{{- end -}}
{{- end -}}

{{- define "snippet.oncall.telegram.env" -}}
{{- if .Values.oncall.telegram.enabled -}}
- name: FEATURE_TELEGRAM_INTEGRATION_ENABLED
  value: {{ .Values.oncall.telegram.enabled | toString | title | quote }}
- name: TELEGRAM_WEBHOOK_HOST
  value: {{ .Values.oncall.telegram.webhookUrl | default "" | quote }}
- name: TELEGRAM_TOKEN
  value: {{ .Values.oncall.telegram.token | default "" | quote }}
{{- else -}}
- name: FEATURE_TELEGRAM_INTEGRATION_ENABLED
  value: {{ .Values.oncall.telegram.enabled | toString | title | quote }}
{{- end -}}
{{- end -}}

{{- define "snippet.oncall.twilio.env" -}}
{{- with .Values.oncall.twilio -}}
{{- if .accountSid }}
- name: TWILIO_ACCOUNT_SID
  value: {{ .accountSid | quote }}
{{- end -}}
{{- if .authToken }}
- name: TWILIO_AUTH_TOKEN
  value: {{ .authToken | quote }}
{{- end -}}
{{- if .phoneNumber }}
- name: TWILIO_NUMBER
  value: {{ .phoneNumber | quote }}
{{- end -}}
{{- if .verifySid }}
- name: TWILIO_VERIFY_SERVICE_SID
  value: {{ .verifySid | quote }}
{{- end -}}
{{- if .apiKeySid }}
- name: TWILIO_API_KEY_SID
  value: {{ .apiKeySid | quote }}
{{- end -}}
{{- if .apiKeySecret }}
- name: TWILIO_API_KEY_SECRET
  value: {{ .apiKeySecret | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "snippet.celery.env" -}}
{{- if .Values.celery.worker_queue }}
- name: CELERY_WORKER_QUEUE
  value: {{ .Values.celery.worker_queue }}
{{- end -}}
{{- if .Values.celery.worker_concurrency }}
- name: CELERY_WORKER_CONCURRENCY
  value: {{ .Values.celery.worker_concurrency | quote }}
{{- end -}}
{{- if .Values.celery.worker_max_tasks_per_child }}
- name: CELERY_WORKER_MAX_TASKS_PER_CHILD
  value: {{ .Values.celery.worker_max_tasks_per_child | quote }}
{{- end -}}
{{- if .Values.celery.worker_beat_enabled }}
- name: CELERY_WORKER_BEAT_ENABLED
  value: {{ .Values.celery.worker_beat_enabled | quote }}
{{- end -}}
{{- if .Values.celery.worker_shutdown_interval }}
- name: CELERY_WORKER_SHUTDOWN_INTERVAL
  value: {{ .Values.celery.worker_shutdown_interval }}
{{- end -}}
{{- end -}}

{{- define "snippet.mysql.env" -}}
- name: MYSQL_HOST
  value: {{ include "snippet.mysql.host" . }}
- name: MYSQL_PORT
  value: {{ include "snippet.mysql.port" . }}
- name: MYSQL_DB_NAME
  value: {{ include "snippet.mysql.db" . }}
- name: MYSQL_USER
  value: {{ include "snippet.mysql.user" . }}
- name: MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "snippet.mysql.password.secret.name" . }}
      key: mariadb-root-password
{{- end }}

{{- define "snippet.mysql.password.secret.name" -}}
{{- if and (not .Values.mariadb.enabled) .Values.externalMysql.password -}}
{{ include "oncall.fullname" . }}-mysql-external
{{- else -}}
{{ include "oncall.mariadb.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "snippet.mysql.host" -}}
{{- if and (not .Values.mariadb.enabled) .Values.externalMysql.host -}}
{{- required "externalMysql.host is required if not mariadb.enabled" .Values.externalMysql.host | quote }}
{{- else -}}
{{ include "oncall.mariadb.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "snippet.mysql.port" -}}
{{- if and (not .Values.mariadb.enabled) .Values.externalMysql.port -}}
{{- required "externalMysql.port is required if not mariadb.enabled"  .Values.externalMysql.port | quote }}
{{- else -}}
"3306"
{{- end -}}
{{- end -}}

{{- define "snippet.mysql.db" -}}
{{- if and (not .Values.mariadb.enabled) .Values.externalMysql.db_name -}}
{{- required "externalMysql.db is required if not mariadb.enabled" .Values.externalMysql.db_name | quote}}
{{- else -}}
"oncall"
{{- end -}}
{{- end -}}

{{- define "snippet.mysql.user" -}}
{{- if and (not .Values.mariadb.enabled) .Values.externalMysql.user -}}
{{- .Values.externalMysql.user | quote }}
{{- else -}}
"root"
{{- end -}}
{{- end -}}

{{- define "snippet.postgresql.env" -}}
- name: DATABASE_TYPE
  value: {{ .Values.database.type }}
- name: DATABASE_HOST
  value: {{ include "snippet.postgresql.host" . }}
- name: DATABASE_PORT
  value: {{ include "snippet.postgresql.port" . }}
- name: DATABASE_NAME
  value: {{ include "snippet.postgresql.db" . }}
- name: DATABASE_USER
  value: {{ include "snippet.postgresql.user" . }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "snippet.postgresql.password.secret.name" . }}
      key: {{ include "snippet.postgresql.password.secret.key" . }}
{{- end }}

{{- define "snippet.postgresql.password.secret.name" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.password -}}
{{ include "oncall.fullname" . }}-postgresql-external
{{- else if and (not .Values.postgresql.enabled) .Values.externalPostgresql.existingSecret -}}
{{ .Values.externalPostgresql.existingSecret }}
{{- else -}}
{{ include "oncall.postgresql.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "snippet.postgresql.password.secret.key" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.passwordKey -}}
{{ .Values.externalPostgresql.passwordKey }}
{{- else -}}
"postgres-password"
{{- end -}}
{{- end -}}

{{- define "snippet.postgresql.host" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.host -}}
{{- required "externalPostgresql.host is required if not postgresql.enabled" .Values.externalPostgresql.host | quote }}
{{- else -}}
{{ include "oncall.postgresql.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "snippet.postgresql.port" -}}
{{- if and (not .Values.mariadb.enabled) .Values.externalPostgresql.port -}}
{{- required "externalPostgresql.port is required if not postgresql.enabled"  .Values.externalPostgresql.port | quote }}
{{- else -}}
"5432"
{{- end -}}
{{- end -}}

{{- define "snippet.postgresql.db" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.db -}}
{{- required "externalPostgresql.db is required if not postgresql.enabled" .Values.externalPostgresql.db | quote}}
{{- else -}}
"oncall"
{{- end -}}
{{- end -}}

{{- define "snippet.postgresql.user" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.user -}}
{{- .Values.externalPostgresql.user | quote}}
{{- else -}}
"postgres"
{{- end -}}
{{- end -}}

{{- define "snippet.rabbitmq.env" -}}
{{- if eq .Values.broker.type "rabbitmq" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.existingSecret .Values.externalRabbitmq.usernameKey (not .Values.externalRabbitmq.user) }}
- name: RABBITMQ_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "snippet.rabbitmq.password.secret.name" . }}
      key: {{ .Values.externalRabbitmq.usernameKey }}
{{- else }}
- name: RABBITMQ_USERNAME
  value: {{ include "snippet.rabbitmq.user" . }}
{{- end }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "snippet.rabbitmq.password.secret.name" . }}
      key: {{ include "snippet.rabbitmq.password.secret.key" . }}
- name: RABBITMQ_HOST
  value: {{ include "snippet.rabbitmq.host" . }}
- name: RABBITMQ_PORT
  value: {{ include "snippet.rabbitmq.port" . }}
- name: RABBITMQ_PROTOCOL
  value: {{ include "snippet.rabbitmq.protocol" . }}
- name: RABBITMQ_VHOST
  value: {{ include "snippet.rabbitmq.vhost" . }}
{{- end }}
{{- end -}}

{{- define "snippet.rabbitmq.user" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.user -}}
{{- required "externalRabbitmq.user is required if not rabbitmq.enabled" .Values.externalRabbitmq.user | quote }}
{{- else -}}
"user"
{{- end -}}
{{- end -}}

{{- define "snippet.rabbitmq.host" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.host -}}
{{- required "externalRabbitmq.host is required if not rabbitmq.enabled" .Values.externalRabbitmq.host | quote }}
{{- else -}}
{{ include "oncall.rabbitmq.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "snippet.rabbitmq.port" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.port -}}
{{- required "externalRabbitmq.port is required if not rabbitmq.enabled" .Values.externalRabbitmq.port | quote }}
{{- else -}}
"5672"
{{- end -}}
{{- end -}}

{{- define "snippet.rabbitmq.protocol" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.protocol -}}
{{ .Values.externalRabbitmq.protocol | quote }}
{{- else -}}
"amqp"
{{- end -}}
{{- end -}}

{{- define "snippet.rabbitmq.vhost" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.vhost -}}
{{ .Values.externalRabbitmq.vhost | quote }}
{{- else -}}
""
{{- end -}}
{{- end -}}

{{- define "snippet.rabbitmq.password.secret.name" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.password -}}
{{ include "oncall.fullname" . }}-rabbitmq-external
{{- else if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.existingSecret -}}
{{ .Values.externalRabbitmq.existingSecret }}
{{- else -}}
{{ include "oncall.rabbitmq.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "snippet.rabbitmq.password.secret.key" -}}
{{- if and (not .Values.rabbitmq.enabled) .Values.externalRabbitmq.passwordKey -}}
{{ .Values.externalRabbitmq.passwordKey }}
{{- else -}}
rabbitmq-password
{{- end -}}
{{- end -}}

{{- define "snippet.redis.host" -}}
{{- if and (not .Values.redis.enabled) .Values.externalRedis.host -}}
{{- required "externalRedis.host is required if not redis.enabled" .Values.externalRedis.host | quote }}
{{- else -}}
{{ include "oncall.redis.fullname" . }}-master
{{- end -}}
{{- end -}}

{{- define "snippet.redis.password.secret.name" -}}
{{- if and (not .Values.redis.enabled) .Values.externalRedis.password -}}
{{ include "oncall.fullname" . }}-redis-external
{{- else -}}
{{ include "oncall.redis.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "snippet.redis.env" -}}
- name: REDIS_HOST
  value: {{ include "snippet.redis.host" . }}
- name: REDIS_PORT
  value: "6379"
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "snippet.redis.password.secret.name" . }}
      key: redis-password
{{- end }}

{{- define "snippet.oncall.smtp.env" -}}
{{- if .Values.oncall.smtp.enabled -}}
- name: FEATURE_EMAIL_INTEGRATION_ENABLED
  value: {{ .Values.oncall.smtp.enabled | toString | title | quote }}
- name: EMAIL_HOST
  value: {{ .Values.oncall.smtp.host | quote }}
- name: EMAIL_PORT
  value: {{ .Values.oncall.smtp.port | default "587" | quote }}
- name: EMAIL_HOST_USER
  value: {{ .Values.oncall.smtp.username | quote }}
- name: EMAIL_HOST_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "oncall.fullname" . }}-smtp
      key: smtp-password
- name: EMAIL_USE_TLS
  value: {{ .Values.oncall.smtp.tls | toString | title | quote }}
- name: EMAIL_FROM_ADDRESS
  value: {{ .Values.oncall.smtp.fromEmail | quote }}
{{- else -}}
- name: FEATURE_EMAIL_INTEGRATION_ENABLED
  value: {{ .Values.oncall.smtp.enabled | toString | title | quote }}
{{- end -}}
{{- end }}
