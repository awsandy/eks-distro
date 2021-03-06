#sudo snap install helm --classic
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
cat <<EOF> config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.169.147.240-10.169.147.250
EOF
kubectl apply -f config.yaml
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik

kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
#wget https://raw.githubusercontent.com/deep75/fcdemo3/master/deployment2.yml

kubectl apply -f deployment.yml
kubectl apply -f ingress-v1-19.yml
kubectl get po,svc -A

# ssh -R 80:10.169.147.240:80 ssh.localhost.run
# browse
# https://root-eabcdef.localhost.run

# port forward traefik
#kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output name) --address 0.0.0.0 9000:9000



#kubectl port-forward -n weave $(kubectl get -n weave pod --selector=weave-scope-component=app  -o jsonpath='{.items..metadata.name}') --address 0.0.0.0 4040