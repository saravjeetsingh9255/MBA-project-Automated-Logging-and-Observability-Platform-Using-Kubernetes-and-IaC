resource "kubernetes_manifest" "api_deployment" {
  manifest = yamldecode(file("${path.module}/../k8s/api-deployment.yml"))

  depends_on = [
    kubernetes_namespace.perfmonitor
  ]
}

resource "kubernetes_manifest" "api_service" {
  manifest = yamldecode(file("${path.module}/../k8s/api-service.yml"))

  depends_on = [
    kubernetes_manifest.api_deployment
  ]
}

resource "kubernetes_manifest" "frontend_deployment" {
  manifest = yamldecode(file("${path.module}/../k8s/frontend-deployment.yml"))

  depends_on = [
    kubernetes_namespace.perfmonitor
  ]
}

resource "kubernetes_manifest" "frontend_service" {
  manifest = yamldecode(file("${path.module}/../k8s/frontend-service.yml"))

  depends_on = [
    kubernetes_manifest.frontend_deployment
  ]
}

resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(file("${path.module}/../k8s/ingress.yml"))

  depends_on = [
    kubernetes_manifest.api_service,
    kubernetes_manifest.frontend_service
  ]
}