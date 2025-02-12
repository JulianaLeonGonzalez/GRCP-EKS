# Despliegue de microservicios gRPC en EKS


La siguiente solución describe cómo utilizar los módulos de Terraform presentes en el actual repositorio para el despliegue automático de microservicios basados en gRPC en un clúster de Amazon EKS.



## Arquitectura de la solución


La solución comienza con módulo reutilizable de terraform, diseñado para crear los componentes de **Networking** requeridos para exponer de forma segura diferentes microservicios mediante un **Application Load Balancer** y a su vez permitir la comunicación entre ellos bajo el protocolo **gRCP**.
El segundo módulo de terraform se centra en la creación de un **clúster de EKS** con los accesos requeridos para alojar y gestionar eficientemente los microservicios.
Finalmente el tercer módulo de terraform se dedica a garantizar un despliegue fluido y automatizado de los microservicios mediante un pipeline **CI/CD** en **AWS CodeBuild**, asegurando así la entrega contínua.

El siguiente diagrama ilustra la arquitectura de la solución:

![img.png](ArchitectureDiagram.png)

#Pasos

El primer paso es ubicarnos en el directorio principal _GRCP-EKS_ y ejecutar el siguiente comando:

```bash
kubectl apply -f auth-configmap.yaml 
```
Ahora 

```bash
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=<eks_cluster_name> --approve

Ejemplo:

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=grpc-cluster --approve
```

```bash
eksctl create iamserviceaccount --cluster=grpc-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::908642484012:policy/AWSLoadBalancerControllerIAMPolicy --approve --override-existing-serviceaccounts


Ejemplo:

eksctl create iamserviceaccount --cluster=grpc-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::908642484012:policy/AWSLoadBalancerControllerIAMPolicy --approve --override-existing-serviceaccounts
```