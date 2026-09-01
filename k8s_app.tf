resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "production-apps"
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    app_env = "production"
    version = "1.0.0"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "nginx_hpa" {
  metadata {
    name      = "nginx-autoscaler"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    scale_target_ref {
      kind        = "Deployment"
      name        = kubernetes_deployment.nginx.metadata[0].name
      api_version = "apps/v1"
    }

    min_replicas                      = 2
    max_replicas                      = 10
    target_cpu_utilization_percentage = 50
  }
}
