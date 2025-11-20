#################################
# EKS CLUSTER DATA FOR PROVIDERS
#################################

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.this.name
}

#################################
# KUBERNETES + HELM PROVIDERS
#################################

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}


#################################
# OIDC PROVIDER FOR IRSA (ALB)
#################################

resource "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  # Standard EKS OIDC root CA thumbprint for the issuer
  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da0afd10f6b"
  ]
}

#################################
# IAM POLICY FOR AWS LOAD BALANCER CONTROLLER
#################################

# NOTE: You must create alb-iam-policy.json in this folder with the
# official AWS Load Balancer Controller IAM policy JSON.

data "aws_iam_policy" "alb_controller" {
  arn = "arn:aws:iam::682033491815:policy/AWSLoadBalancerControllerIAMPolicy"
}

#resource "aws_iam_policy" "alb_controller" {
#  name   = "AWSLoadBalancerControllerIAMPolicy"
#  policy = file("${path.module}/alb-iam-policy.json")
#}

#################################
# IAM ROLE FOR AWS LOAD BALANCER CONTROLLER (IRSA)
#################################

data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test = "StringEquals"
      # e.g. oidc.eks.us-east-1.amazonaws.com/id/XXXX:sub
      variable = "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }

    condition {
      test = "StringEquals"
      # e.g. oidc.eks.us-east-1.amazonaws.com/id/XXXX:aud
      variable = "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:aud"

      values = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json

  tags = {
    Name = "AmazonEKSLoadBalancerControllerRole"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = data.aws_iam_policy.alb_controller.arn
}

#################################
# K8S SERVICE ACCOUNT FOR ALB CONTROLLER (IRSA)
#################################

#resource "kubernetes_service_account" "alb_sa" {
# metadata {
#  name      = "aws-load-balancer-controller"
# namespace = "kube-system"

#labels = {
# "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#"app.kubernetes.io/component" = "controller"
#}

#annotations = {
# "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
#}
#}
#}