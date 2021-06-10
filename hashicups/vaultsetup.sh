#!/bin/bash
set -v



export ROOT_TOKEN='root'


kubectl exec -it vault-0 -- vault login $ROOT_TOKEN

#################################
# Transit-app-example Vault setup
#################################

# Enable our secret engine
kubectl exec -it vault-0 -- vault secrets enable transit
kubectl exec -it vault-0 -- vault write -f transit/keys/payments


sleep 10


#Create Vault policy used by Nomad job
echo '
path "transit/encrypt/payments" {
  capabilities = ["update"]
}'| kubectl exec -it vault-0 -- vault policy write payments-api -

kubectl exec -it vault-0 -- vault auth enable kubernetes
export VAULT_SA_NAME=$(kubectl get sa vault -o jsonpath="{.secrets[*]['name']}")
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
export K8S_HOST="https://kubernetes.default.svc:443"
kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
        token_reviewer_jwt="$SA_JWT_TOKEN" \
        kubernetes_host="$K8S_HOST" \
        kubernetes_ca_cert="$SA_CA_CRT"


kubectl exec -it vault-0 -- vault write auth/kubernetes/role/example \
        bound_service_account_names=payments-api  \
        bound_service_account_namespaces=default \
        policies=payments-api \
        ttl=24h
