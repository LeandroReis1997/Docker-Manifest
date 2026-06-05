# ECR Docker Login Script
# Autentica Docker no Amazon ECR para puxar imagens
# Usage: ./ecr-login.ps1

param(
    [string]$Region = "us-east-1",
    [string]$AwsProfile = "default"
)

# Variables
$AwsAccountId = "171430923691"
$EcrRegistry = "$AwsAccountId.dkr.ecr.$Region.amazonaws.com"

Write-Host "Autenticando Docker no ECR..." -ForegroundColor Cyan
Write-Host "Registry: $EcrRegistry" -ForegroundColor Gray
Write-Host "Region: $Region" -ForegroundColor Gray
Write-Host "Profile: $AwsProfile" -ForegroundColor Gray

try {
    # Get login token from AWS ECR and pipe to docker login
    $token = aws ecr get-login-password --region $Region --profile $AwsProfile
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erro ao obter token ECR. Verifique suas credenciais AWS." -ForegroundColor Red
        exit 1
    }
    
    # Login to ECR
    $token | docker login --username AWS --password-stdin $EcrRegistry
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Autenticacao bem-sucedida!" -ForegroundColor Green
        Write-Host "Agora voce pode fazer pull de imagens do ECR:" -ForegroundColor Green
        Write-Host "  docker pull $EcrRegistry/filazero-admin-backend:v1.0.0" -ForegroundColor Yellow
        Write-Host "  docker pull $EcrRegistry/filazero-admin-frontend:v1.0.0" -ForegroundColor Yellow
    } else {
        Write-Host "Erro ao fazer login no Docker. Verifique a saida acima." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Erro: $_" -ForegroundColor Red
    exit 1
}
