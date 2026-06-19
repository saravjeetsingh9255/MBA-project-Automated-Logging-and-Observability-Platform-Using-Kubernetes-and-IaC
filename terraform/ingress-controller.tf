resource "helm_release" "ingress_nginx" {
  name      = "ingress-nginx"
  namespace = kubernetes_namespace.ingress_nginx.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  timeout = 600
  wait    = false

  depends_on = [
    kubernetes_namespace.ingress_nginx
  ]
}