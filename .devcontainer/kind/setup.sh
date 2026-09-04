#!/bin/bash
set -e

# Color definitions
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                 Kind Cluster Setup Script                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# System requirements check
echo -e "${CYAN}📋 System Requirements:${NC}"
echo -e "${YELLOW} • Disk Space: 20-30+ GB available${NC}"
echo -e "${YELLOW} • Memory: 8+ GB RAM (16+ GB recommended)${NC}"
echo -e "${YELLOW} • Docker: daemon running with sufficient resources${NC}"
echo ""

# Architecture detection
if [ $(uname -m) = x86_64 ]; then
    ARCH="amd64"
elif [ $(uname -m) = aarch64 ]; then
    ARCH="arm64"
else
    echo -e "${RED}Unsupported architecture: $(uname -m)${NC}"
    exit 1
fi
echo -e "${BLUE}Detected architecture: $ARCH${NC}"

# Docker daemon check
echo -e "${BLUE}Waiting for Docker daemon to be ready...${NC}"
timeout 30 bash -c 'until docker info > /dev/null 2>&1; do sleep 1; done' || {
    echo -e "${RED}Docker daemon failed to start within 30 seconds${NC}"
    exit 1
}
echo -e "${GREEN}Docker daemon is ready${NC}"

# Install Kind
KIND_RELEASE="v0.29.0"
echo -e "${BLUE}Installing Kind...${NC}"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/$KIND_RELEASE/kind-linux-${ARCH}
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create cluster
kind delete cluster --name kind || true
echo -e "${BLUE}Creating kind cluster with fixed ports...${NC}"
kind create cluster --name kind --wait=180s

# Store kubeconfig
kind get kubeconfig --name kind --internal=false > ~/.kube/config

# Test cluster
if kubectl get nodes > /dev/null 2>&1; then
    echo -e "${GREEN}Kind cluster ready${NC}"
    kubectl cluster-info
    kubectl get nodes
    kubectl get pods --all-namespaces
else
    echo -e "${RED}Cluster failed to start properly${NC}"
    docker logs kind-control-plane
    exit 1
fi

# Install chart-testing
CT_VERSION="v3.13.0"
echo -e "${BLUE}Installing chart-testing...${NC}"
curl -Lo ct.tar.gz https://github.com/helm/chart-testing/releases/download/$CT_VERSION/chart-testing_${CT_VERSION#v}_linux_${ARCH}.tar.gz
tar -xzf ct.tar.gz
chmod +x ct
sudo mv ct /usr/local/bin/ct
rm -rf ct.tar.gz etc/

# Install Python dependencies for chart-testing
echo -e "${BLUE}Installing Python dependencies for chart-testing...${NC}"
pip index versions yamllint
YAMLLINT_VERSION="1.37.1"
pip install yamllint==${YAMLLINT_VERSION}
echo -e "${GREEN}Python dependencies installed${NC}"

# Create chart-testing configuration files
echo -e "${BLUE}Creating chart-testing configuration files...${NC}"

# Create ct.yaml
echo -e "${CYAN}Creating ct.yaml...${NC}"
cat > ct.yaml << EOF
chart-dirs:
  - charts
validate-maintainers: false
check-version-increment: false
validate-chart-schema: false
EOF
echo -e "${GREEN}✓ ct.yaml created${NC}"

# Create lintconf.yaml
echo -e "${CYAN}Creating lintconf.yaml...${NC}"
cat > lintconf.yaml << EOF
---
rules:
  line-length: disable
EOF
echo -e "${GREEN}✓ lintconf.yaml created${NC}"

echo -e "${GREEN}All configuration files created successfully${NC}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Sample Commands                           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}Chart-testing commands:${NC}"
echo -e "${YELLOW}# List changed charts:${NC}"
echo -e "ct list-changed --target-branch master"
echo ""
echo -e "${YELLOW}# Lint changed charts:${NC}"
echo -e "ct lint --debug --validate-maintainers=false --target-branch master"
echo ""
echo -e "${YELLOW}# Lint all charts:${NC}"
echo -e "ct lint --debug --validate-maintainers=false --all"
echo ""
echo -e "${YELLOW}# Install test (dry-run):${NC}"
echo -e "ct install --debug --helm-extra-args='--dry-run'"
echo ""

echo -e "${CYAN}Helm commands:${NC}"
echo -e "${YELLOW}# Lint specific chart:${NC}"
echo -e "helm lint charts/rucio-server/"
echo ""
echo -e "${YELLOW}# Template chart:${NC}"
echo -e "helm template charts/rucio-server/"
echo ""
echo -e "${YELLOW}# Check dependencies:${NC}"
echo -e "helm dependency update charts/rucio-server/"
echo ""

echo -e "${GREEN}Setup complete! Use the commands above to test your charts.${NC}"