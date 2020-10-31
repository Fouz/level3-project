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

ns:
	kubectl create namespace test
	kubectl create namespace prod
	kubectl create namespace logging
	kubectl create namespace monitor

elf-kibana: 
	sh monitoring/elf.sh
	sh monitoring/pro-graf.sh

services-up-test:

	kubectl apply -f config/ -n test
	kubectl apply -f user/tekton -f user/user-test -f user/tekton-db -f user/user-db-test -n test
	kubectl apply -f queue-master/tekton -f queue-master/qm-test -n test
	kubectl apply -f payment/tekton -f payment/test -n test
	kubectl apply -f orders/tekton -f orders/o-test -n test
	kubectl apply -f load-test/tekton -n test
	kubectl apply -f front-end/tekton -f front-end/test -n test
	kubectl apply -f catalogue/tekton -f catalogue/cata-test -f catalogue/tekton-db -f catalogue/cata-db-test -n test
	kubectl apply -f carts/tekton -f carts/carts-test -n test
	kubectl apply -f shipping/tekton -f shipping/test -n test

services-down-test:

	kubectl delete -f config/ -n test
	kubectl delete -f user/tekton -f user/user-test -f user/tekton-db -f user/user-db-test -n test
	kubectl delete -f queue-master/tekton -f queue-master/qm-test -n test
	kubectl delete -f payment/tekton -f payment/test -n test
	kubectl delete -f orders/tekton -f orders/o-test -n test
	kubectl delete -f load-test/tekton -n test
	kubectl delete -f front-end/tekton -f front-end/test -n test
	kubectl delete -f catalogue/tekton -f catalogue/cata-test -f catalogue/tekton-db -f catalogue/cata-db-test -n test
	kubectl delete -f carts/tekton -f carts/carts-test -n test
	kubectl delete -f shipping/tekton -f shipping/test -n test
	kubectl delete all --all -n test 

services-up-prod:

	kubectl apply -f config/ -n prod
	kubectl apply -f user/tekton -f user/user-prod -f user/tekton-db -f user/user-db-prod -n prod
	kubectl apply -f queue-master/tekton -f queue-master/qm-prod -n prod
	kubectl apply -f payment/tekton -f payment/prod -n prod
	kubectl apply -f orders/tekton -f orders/o-prod -n prod
	kubectl apply -f load-prod/tekton -n prod
	kubectl apply -f front-end/tekton -f front-end/prod -n prod
	kubectl apply -f catalogue/tekton -f catalogue/cata-prod -f catalogue/tekton-db -f catalogue/cata-db-prod -n prod
	kubectl apply -f carts/tekton -f carts/carts-prod -n prod
	kubectl apply -f shipping/tekton -f shipping/prod -n prod
	kubectl apply -f carts/tekton -n prod

services-down-prod:

	kubectl delete -f config/ -n prod
	kubectl delete -f user/tekton -f user/user-prod -f user/tekton-db -f user/user-db-prod -n prod
	kubectl delete -f queue-master/tekton -f queue-master/qm-prod -n prod
	kubectl delete -f payment/tekton -f payment/prod -n prod
	kubectl delete -f orders/tekton -f orders/o-prod -n prod
	kubectl delete -f load-prod/tekton -n prod
	kubectl delete -f front-end/tekton -f front-end/prod -n prod
	kubectl delete -f catalogue/tekton -f catalogue/cata-prod -f catalogue/tekton-db -f catalogue/cata-db-prod -n prod
	kubectl delete -f carts/tekton -f carts/carts-prod -n prod
	kubectl delete -f shipping/tekton -f shipping/prod -n prod
	kubectl delete -f carts/tekton -n prod
	kubectl delete all --all -n prod 

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
