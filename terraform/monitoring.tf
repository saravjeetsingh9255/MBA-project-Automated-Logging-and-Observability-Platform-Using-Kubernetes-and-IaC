resource "helm_release" "kube_prometheus_stack" {
  name      = "monitoring"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    file("${path.module}/../k8s/monitoring-values.yml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}