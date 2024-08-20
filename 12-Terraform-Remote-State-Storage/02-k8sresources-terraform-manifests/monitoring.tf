resource "time_sleep" "wait_for_kubernetes" {

  # depends_on = [
  #   module.ekscluster
  # ]

  create_duration = "20s"
}

resource "kubernetes_namespace" "kube-namespace" {
  depends_on = [time_sleep.wait_for_kubernetes]
  metadata {

    name = "prometheus"
  }
}


resource "kubernetes_namespace" "monitor_namespace" {
  metadata {
    name = var.namespace_monitoring
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace_argocd
  }
}


resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argo_cd_version
  namespace        = kubernetes_namespace.argocd.id
  create_namespace = false
  skip_crds        = true

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.ingress.enabled"
    value = "false"
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = var.namespace_monitoring # kubernetes_namespace.monitor_namespace.metadata[0].name
  version          = var.grafana_version
  create_namespace = false
  values = [
    file("${path.module}/yaml-helm/grafana.yaml"),
    # yamlencode(var.settings_grafana)
  ]

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  depends_on = [kubernetes_namespace.monitor_namespace]
}


resource "helm_release" "prometheus" {
  depends_on       = [kubernetes_namespace.kube-namespace]
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.kube-namespace.id
  create_namespace = true
  version          = "51.3.0"
  values = [
    file("values.yaml")
  ]
  timeout = 600


  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}