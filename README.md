# vagrant-kubernetes
basic example for test 

after run `vagrant up `

`vagrant ssh` and 
`cd /vagrant`

to install knative  and metallb 

`chmod +x /vagrant/install-knative`


`/vagrant/install-knative`


it would install and configure the istio ingress

config metallb

`kubectl /f /vagrant/metallb/config.yml`

usually take some minutes until the system are ready

you can check with 

`kubectl get services --all-namespaces`

and check for  external ip, ehn the istio ingress have a valid ip the system are ready to work with it

you can run the examples under kubernetes or knative folders

you can declare services as loaBalancer and they will have an external ip 

moreover the knative services will have a domain

for the example under knative/serving/service.yaml

you can run with 

`kubectl apply -f  /vagrant/knative/serving/service.yaml `


`kubectl get ksvc helloworld-python `

the last command should show you the url to access the microservice in your browser


moreover you can check the creation run and deletion of pod with 

`kubectl get pods`





basic vagrant configuration based on this [project](https://bitbucket.org/exxsyseng/k8s_ubuntu/src/master/)