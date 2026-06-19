

resource "kubernetes_manifest" "elasticsearch" {
  manifest = yamldecode(file("${path.module}/../k8s/elasticsearch.yml"))

  field_manager {
    name            = "terraform"
    force_conflicts = true
  }

  depends_on = [
    kubernetes_namespace.logging
  ]
}

resource "kubernetes_manifest" "kibana" {
  manifest = yamldecode(file("${path.module}/../k8s/kibana.yml"))

  field_manager {
    name            = "terraform"
    force_conflicts = true
  }

  depends_on = [
    kubernetes_manifest.elasticsearch
  ]
}