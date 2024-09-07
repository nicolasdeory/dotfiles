##########
## KUBE ##
##########
function fkubectl () {
    context=${1:-minikube}
    shift
	    $HOME/bin/kubectl --kubeconfig $HOME/.kube/config --context ${context} $*
}
alias kubectl='fkubectl minikube'
alias kubectl-hg-stage-oh='fkubectl eks_hg-stage-oh-eks-shared'
alias kubectl-hg-prod-nv='fkubectl eks_hg-prod-nv-eks-shared'
function fkubectl-board() {
    context="${1-eks_stage-oh-eks-shared}"
    port=${2-:8001}
    cluster=${3-stage-oh-eks-shared}
    profile="${4-default}"
    echo "go to:  https://localhost:${port}"
    AWS_PROFILE=${profile} aws-iam-authenticator token -i ${cluster} --token-only | pbcopy
    fkubectl ${context} port-forward svc/kubernetes-dashboard -n kubernetes-dashboard ${port}:443
}
alias kubectl-minikube-board='eval $(minikube docker-env) && minikube dashboard'
alias kubectl-hg-stage-oh-board='fkubectl-board eks_hg-stage-oh-eks-shared 8011 hg-stage-oh-eks-shared homagames'
alias kubectl-hg-prod-nv-board='fkubectl-board eks_hg-prod-nv-eks-shared 9011 hg-prod-nv-eks-shared homagames'
