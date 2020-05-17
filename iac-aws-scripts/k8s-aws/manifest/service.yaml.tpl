apiVersion: v1
kind: Service
metadata:
  name: app
  labels:
    app: app
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${cert}
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
spec:
  type: LoadBalancer
  selector:
    app: app
  ports:
    - port: 443
      targetPort: 5000
  loadBalancerSourceRanges:
  - ${trusted}
