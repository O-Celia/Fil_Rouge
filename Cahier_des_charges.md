# Déploiement de WordPress avec Terraform, Kubernetes (AKS), Docker, Jenkins, et outils de sécurité et de supervision

## 1. Introduction

Ce cahier des charges décrit les spécifications et les exigences pour le déploiement de WordPress sur un cluster Kubernetes (AKS) en utilisant Terraform pour l'infrastructure, Docker pour Jenkins, et Jenkins pour WordPress. Le projet comprend également l'intégration d'outils de sécurité tels que WPScan, OWASP Dependency Check, Sonar Cloud, Clair et Bandit (2 derniers optionnels), ainsi que la mise en place de fonctionnalités de sécurité avancées telles que le TLS, l'authentification à deux facteurs et la limite de tentatives de connexion. Enfin, le projet inclut la mise en place de Prometheus et Grafana comme outils de supervision.

## 2. Objectifs du projet

- Déployer le cluster Azure Kubernetes Service (AKS) en utilisant Terraform.
- Utiliser Docker pour déployer Jenkins sur le cluster AKS.
- Configurer Jenkins pour automatiser le déploiement de WordPress sur le cluster à partir de fichiers YAML stockés sur GitHub.
- Configurer le pod de déploiement de WordPress avec autoscaler.
- Configurer l'Ingress Azure pour exposer WordPress au trafic entrant.
- Déployer une base de données MySQL pour WordPress sur le cluster.
- Effectuer des tests de sécurité avec WPScan, OWASP Dependency Check, Sonar Cloud.
- Mettre en place le chiffrement TLS pour sécuriser la communication avec WordPress.
- Implémenter l'authentification à deux facteurs pour l'accès à WordPress.
- Configurer une limite de tentatives de connexion pour protéger contre les attaques par force brute .
- Mettre en place Prometheus et Grafana pour superviser l'infrastructure et les performances de WordPress.

## 3. Exigences fonctionnelles

### 3.1 Déploiement de l'infrastructure

Terraform est un outil d'infrastructure en tant que code qui permet de déployer et de gérer l'infrastructure de manière reproductible. Dans ce projet, Terraform sera utilisé pour déployer l'infrastructure Kubernetes sur Azure Kubernetes Service (AKS). Le cluster AKS fournit une plateforme Kubernetes gérée qui permet de déployer, gérer et orchestrer les conteneurs de manière évolutive. Le cluster AKS sera utilisé pour exécuter les conteneurs WordPress et les autres composants nécessaires.

- Utiliser Terraform pour déployer un cluster AKS sur Azure.

### 3.2 Déploiement de WordPress

Jenkins est un outil d'intégration continue et de déploiement continu (CI/CD) largement utilisé. Dans ce projet, Jenkins sera déployé à l'aide de Docker et Terraform sur le cluster AKS. Les fichiers YAML stockés sur GitHub contiendront les instructions nécessaires pour déployer WordPress avec le cluster AKS avec les configurations spécifiques souhaitées. Jenkins utilisera ces fichiers pour automatiser le déploiement de WordPress avec AKS, garantissant ainsi une mise en production rapide et reproductible.

- Utiliser Jenkins pour déployer WordPress avec le cluster AKS à partir de fichiers YAML stockés sur GitHub.
- Configurer Jenkins pour automatiser le déploiement, la mise à jour et la gestion de WordPress.
- Configurer le pod de déploiement dans le cluster AKS avec les ressources nécessaires pour le scaling automatique et avec indicateurs.

### 3.3 Déploiement de la base de données

MySQL est un système de gestion de base de données relationnelle très utilisé. Dans ce projet, MySQL sera déployé sur le cluster AKS à partir d'un fichier YAML sur GitHub pour stocker les données de WordPress. La sécurité de la base de données est essentielle pour protéger les informations sensibles. Des mesures de sécurité appropriées seront mises en place, telles que la configuration des autorisations d'accès et l'application de bonnes pratiques de sécurité pour garantir l'intégrité et la confidentialité des données stockées.

- Configurer une base de données MySQL sur le cluster AKS.
- Assurer la sécurité de la base de données en configurant l'accès et les autorisations appropriées.

### 3.4 Tests de sécurité

Les tests de sécurité, tels que WPScan, OWASP Dependency Check et Sonar Cloud sont utilisés pour identifier les vulnérabilités et les problèmes de sécurité dans les composants logiciels utilisés. Ces tests seront intégrés dans le processus de déploiement de Jenkins afin d'exécuter automatiquement ces tests sur WordPress. Les rapports de tests générés aideront à identifier les problèmes de sécurité potentiels et permettront de prendre les mesures nécessaires pour les résoudre.

- Intégrer les outils de sécurité WPScan, OWASP Dependency Check et Sonar Cloud dans le processus de déploiement de Jenkins pour exécuter des tests de sécurité automatiques sur WordPress.
- Configurer les rapports de tests pour faciliter l'analyse des résultats.

### 3.5 Sécurité avancée (accès)

Pour renforcer la sécurité de l'application WordPress, des configurations avancées seront mises en place. Cela inclut la configuration du chiffrement TLS pour sécuriser la communication entre les utilisateurs et WordPress, l'authentification à deux facteurs pour renforcer l'authentification des utilisateurs, la mise en place d'une limite de tentatives de connexion pour prévenir les attaques par force brute, l'utilisation du RBAC pour gérer les autorisations d'accès aux ressources et l'IP whitelisting pour restreindre l'accès à WordPress à partir d'adresses IP spécifiques.

- Mettre en place le chiffrement TLS pour sécuriser la communication avec WordPress.
- Configurer l'authentification à deux facteurs pour renforcer la sécurité de l'accès à WordPress.
- Limiter le nombre de tentatives de connexion pour prévenir les attaques par force brute.

### 3.6 Supervision de l'infrastructure

Prometheus est un système de surveillance et de collecte de métriques open-source, tandis que Grafana est un outil de visualisation de données. Dans ce projet, Prometheus sera utilisé pour collecter les métriques de l'infrastructure Kubernetes et de WordPress, tandis que Grafana sera utilisé pour visualiser et analyser ces métriques de manière conviviale. Cela permettra aux administrateurs système et aux développeurs de superviser et d'optimiser les performances de l'application WordPress et de l'infrastructure sous-jacente.

- Mettre en place Prometheus pour collecter les métriques de l'infrastructure et de WordPress.
- Configurer Grafana pour visualiser et analyser les métriques de manière conviviale.

## 4. Contraintes techniques

- Utilisation de Terraform pour déployer l'infrastructure.
- Utilisation d'Azure Kubernetes Service (AKS) comme plateforme Kubernetes.
- Utilisation de Docker pour déployer Jenkins.
- Utilisation de fichiers YAML stockés sur GitHub pour le déploiement de WordPress sur l'AKS avec Jenkins.
- Intégration des outils de sécurité WPScan, OWASP Dependency Check et Sonar Cloud.
- Configuration du chiffrement TLS pour la communication avec WordPress.
- Configuration de l'authentification à deux facteurs et de la limite de tentatives de connexion pour renforcer la sécurité.
- Mise en place de Prometheus et Grafana pour la supervision.

## 5. Livrables attendus
- Documentation du déploiement du cluster AKS à l'aide de Terraform.
- Documentation du déploiement de WordPress et des outils de sécurité avec Jenkins.
- Fichiers YAML stockés sur GitHub.
- Rapports de tests de sécurité.
- Documentation de la sécurité avancée.
- Documentation de la mise en place de Prometheus et Grafana pour la supervision.

## 6. Planning et ressources
- Établir un planning détaillé pour chaque étape du projet.
- Allouer les ressources nécessaires pour le déploiement, la configuration et la supervision de l'infrastructure.

## 7. Références
- Documentation de Terraform : https://www.terraform.io/docs/index.html
- Documentation d'Azure Kubernetes Service (AKS) : https://docs.microsoft.com/en-us/azure/aks/
- Documentation de Docker : https://www.docker.com/
- Documentation de Jenkins : https://www.jenkins.io/doc/
- Documentation de WordPress : https://wordpress.org/support/
- Documentation de WPScan : https://wpscan.com/
- Documentation d'OWASP Dependency Check : https://owasp.org/www-project-dependency-check/
- Documentation de Sonar Cloud : https://sonarcloud.io/
- Documentation de Prometheus : https://prometheus.io/docs/
- Documentation de Grafana : https://grafana.com/docs/
