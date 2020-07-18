#!/bin/bash
#install Knative Serving component
echo "[TASK 5] installing knative"
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-crds.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-core.yaml
echo "[TASK 6] installing lstio"
curl -L https://istio.io/downloadIstio | sh -
 cd istio-1.6.5
 export PATH=$PWD/bin:$PATH
 istioctl install --set profile=demo
cat << EOF > ./istio-minimal-operator.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      proxy:
        autoInject: disabled
      useMCP: false
      # The third-party-jwt is not enabled on all k8s.
      # See: https://istio.io/docs/ops/best-practices/security/#configure-third-party-service-account-tokens
      jwtPolicy: first-party-jwt

  addonComponents:
    pilot:
      enabled: true
    prometheus:
      enabled: false

  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
      - name: cluster-local-gateway
        enabled: true
        label:
          istio: cluster-local-gateway
          app: cluster-local-gateway
        k8s:
          service:
            type: ClusterIP
            ports:
            - port: 15020
              name: status-port
            - port: 80
              name: http2
            - port: 443
              name: https
EOF

istioctl manifest apply -f istio-minimal-operator.yaml
echo "[TASK 7] installing knative serving"
#kubectl edit cm config-domain --namespace knative-serving
kubectl apply --filename https://github.com/knative/net-istio/releases/download/v0.15.0/release.yaml
kubectl --namespace istio-system get service istio-ingressgateway
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.15.0/serving-default-domain.yaml

#install Knative Eventing component
kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.16.0/eventing-crds.yaml
kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.16.0/eventing-core.yaml
kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.16.0/in-memory-channel.yaml
kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.16.0/mt-channel-broker.yaml
#install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"