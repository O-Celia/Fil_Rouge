---
title: Wordpress
tags: presentation
slideOptions:
  theme: moon
  transition: 'fade'
  spotlight:
    enabled: true
---

# Déploiement automatisé de WordPress

----

## Pourquoi WordPress ?

- Popularité et facilité d'utilisation : interface conviviale et intuitive, ce qui facilite sa prise en main
- Flexibilité et extensibilité : vaste collection de thèmes et de plugins qui permet de personnaliser facilement
- Support, documentation abondante, communauté active : forums, tutoriels et ressources en ligne pour aider à résoudre les problèmes et trouver des solutions adaptées

---

## Objectifs et ressources

----

### Objectifs

1. Déployer un cluster Azure Kubernetes Service (AKS)
2. Déployer Jenkins sur le cluster AKS.
3. Configurer Jenkins pour automatiser le déploiement de WordPress.
4. Mettre en place des outils de sécurité.
5. Implémenter des fonctionnalités de sécurité avancées .
6. Mettre des outils pour superviser l'infrastructure et les performances de WordPress.

----

### Ressources

- Azure Kubernetes Service
- Terraform
- Docker
- WordPress
- Jenkins
- GitHub

----

### Ressources

- MySQL
- WPScan
- OWASP Dependency Check
- Sonar Cloud
- Prometheus
- Grafana
- (TLS / Authentification à deux facteurs)

---

## Topographie

![](https://hackmd.io/_uploads/H1_6jwqI2.png)


----

## Compétences

- Automatiser la création de serveurs à l’aide de scripts
- Automatiser le déploiement d'une infrastructure
- Sécuriser l’infrastructure
- Mettre l’infrastructure en production dans le cloud

----

## Compétences

- Gérer le stockage des données
- Gérer des containers
- Définir et mettre en place des statistiques de services
- Exploiter une solution de supervision
- (Echanger sur des réseaux professionnels éventuellement en anglais)

---

## Déploiements

----

### Terraform

- Déploiement du cluster AKS dans lequel s'exécutera WordPress et autres composants
- Déploiement de Jenkins en utilisant Docker sur le cluster AKS

----

### Wordpress

- Configuration de Jenkins pour automatiser le déploiement, la mise à jour et la gestion de WordPress à partir de fichiers YAML stockés sur GitHub

----

### Fichiers YAML

- Mise en place de l'autoscaling
- Configuration de l'Ingress Azure pour exposer WordPress au trafic entrant
- Déploiement d'une base de données MySQL sur le cluster AKS pour stocker les données de WordPress

----

### Tests de sécurité

- Intégration des outils de sécurité WPScan, OWASP Dependency Check et Sonar Cloud dans le processus de déploiement de Jenkins pour effectuer des tests de sécurité automatiques sur WordPress.

----

### Sécurité avancée

- Mise en place du chiffrement TLS pour sécuriser la communication avec WordPress.
- Configuration de l'authentification à deux facteurs pour renforcer la sécurité de l'accès à WordPress.
- Mise en place d'une limite de tentatives de connexion pour prévenir les attaques par force brute.

----

### Supervision

- Configuration de Prometheus pour collecter les métriques de l'infrastructure et de WordPress.
- Configuration de Grafana pour visualiser et analyser les métriques.

---

## Livrables

- Documentation du déploiement du cluster AKS à l'aide de Terraform.
- Documentation du déploiement de WordPress et des outils de sécurité avec Jenkins.
- Fichiers YAML stockés sur GitHub.
- Rapports de tests de sécurité.
- Documentation de la sécurité avancée.
- Documentation de la mise en place de Prometheus et Grafana pour la supervision.

---

![](https://hackmd.io/_uploads/SymFnP9I2.png)
