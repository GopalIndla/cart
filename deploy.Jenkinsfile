pipeline {
    agent any 
    parameters {
        string(name: 'APP_VERSION', defaultValue: '403', description: 'Applicaiton Version To Be Deployed') 
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Pick Environment')
    }
    stages {
        stage('Deploying Cart') {
            steps {
                sh "echo Authentication To EKS"
                sh "aws eks update-kubeconfig --name ${ENV}-eks-cluster"
                echo "Deployint to $ENV Cluster"
                sh "kubectl get nodes"
                sh "kubectl apply -f deploy.yaml"
            }
        }
    }
}
