```sh
helm repo add datadog https://helm.datadoghq.com
helm -n datadog install datadog-operator datadog/datadog-operator --create-namespace
kubectl -n datadog create secret generic datadog-secret --from-literal api-key=1868228a46a9593350abb78d9b9ff3b5

# Install Datadog
```sh
kubectl apply -f datadog-agent.yaml
```