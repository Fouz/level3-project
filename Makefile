clone:	
	git clone https://github.com/KnowledgeHut-AWS/k8s-sandbox.git
cluster:
	cd k8s-sandbox && $(MAKE) cluster-up
cicd:
	cd k8s-sandbox && $(MAKE) install-cicd
tkn:
	sudo apt update 
	sudo apt install -y gnupg 
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3EFE0E0A2F2F60AA 
	echo "deb http://ppa.launchpad.net/tektoncd/cli/ubuntu eoan main"|sudo tee /etc/apt/sources.list.d/tektoncd-ubuntu-cli.list 
	sudo apt update && sudo apt install -y tektoncd-cli

install-vault:
	helm install vault hashicorp/vault -f platform/vault/values.yaml -n vault | tee -a output.log
	sudo snap install vault
config:
	k apply -f config/
services-up-test:
	k apply -f user/tekton -f user/tekton-db -n test
	k apply -f queue-master/tekton -n test
	k apply -f payment/tekton -n test
	k apply -f orders/tekton -n test
	k apply -f load-test/tekton -n test
	k apply -f front-end/tekton -n test
	k apply -f catalogue/tekton -f catalogue/tekton-db -n test
	k apply -f carts/tekton -n test

services-down-test:
	k delete -f user/tekton -f user/tekton-db -n test
	k delete -f queue-master/tekton -n test
	k delete -f payment/tekton -n test
	k delete -f orders/tekton -n test
	k delete -f load-test/tekton -n test
	k delete -f front-end/tekton -n test
	k delete -f catalogue/tekton -f catalogue/tekton-db -n test
	k delete -f carts/tekton -n test

services-up-prod:
	k apply -f user/tekton -f user/tekton-db -n prod
	k apply -f queue-master/tekton -n prod
	k apply -f payment/tekton -n prod
	k apply -f orders/tekton -n prod
	k apply -f load-test/tekton -n prod
	k apply -f front-end/tekton -n prod
	k apply -f catalogue/tekton -f catalogue/tekton-db -n prod
	k apply -f carts/tekton -n prod

services-down-prod:
	k delete -f user/tekton -f user/tekton-db -n prod
	k delete -f queue-master/tekton -n prod
	k delete -f payment/tekton -n prod
	k delete -f orders/tekton -n prod
	k delete -f load-test/tekton -n prod
	k delete -f front-end/tekton -n prod
	k delete -f catalogue/tekton -f catalogue/tekton-db -n prod
	k delete -f carts/tekton -n prod

install-ingress:
	echo "Ingress: install" | tee -a output.log
	kubectl apply -n ingress-nginx -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

delete-ingress:
	echo "Ingress: delete" | tee -a output.log
	kubectl delete -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log 2>/dev/null | true

monitoring:
	cd vault-on-k8s && $(MAKE) install-monitoring
	cd vault-on-k8s && $(MAKE) install-logging
