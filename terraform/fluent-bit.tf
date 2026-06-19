data "kubernetes_secret" "elastic_user" {
  metadata {
    name      = "perfmonitor-es-es-elastic-user"
    namespace = "logging"
  }

  depends_on = [
    kubernetes_manifest.elasticsearch
  ]
}

locals {
  elastic_password = try(
    nonsensitive(data.kubernetes_secret.elastic_user.data["elastic"]),
    ""
  )
}

resource "helm_release" "fluent_bit" {
  name      = "fluent-bit"
  namespace = kubernetes_namespace.logging.metadata[0].name

  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"

  values = [
    yamlencode({
      config = {
        service = <<-EOT
          [SERVICE]
              Flush        1
              Log_Level    info
              Daemon       off
              Parsers_File parsers.conf
              HTTP_Server  On
              HTTP_Listen  0.0.0.0
              HTTP_Port    2020
        EOT

        inputs = <<-EOT
          [INPUT]
              Name              tail
              Path              /var/log/containers/*.log
              Parser            cri
              Tag               kube.*
              Refresh_Interval  5
              Mem_Buf_Limit     5MB
              Skip_Long_Lines   On
        EOT

        filters = <<-EOT
          [FILTER]
              Name                kubernetes
              Match               kube.*
              Merge_Log           On
              Keep_Log            Off
              K8S-Logging.Parser  On
              K8S-Logging.Exclude Off
        EOT

        outputs = <<-EOT
          [OUTPUT]
              Name                es
              Match               kube.*
              Host                perfmonitor-es-es-http.logging.svc.cluster.local
              Port                9200
              HTTP_User           elastic
              HTTP_Passwd         ${local.elastic_password}
              TLS                 On
              TLS.Verify          Off
              Logstash_Format     On
              Logstash_Prefix     kubernetes
              Suppress_Type_Name  On
              Retry_Limit         False
        EOT
      }
    })
  ]

  depends_on = [
    kubernetes_manifest.elasticsearch,
    data.kubernetes_secret.elastic_user
  ]
}