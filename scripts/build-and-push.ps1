# Creates the four public Docker Hub images required by k8s/deploy.yaml.
param(
  [string]$DockerUser = "shekhar013",
  [string]$Tag = "1.0.0"
)

$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker Desktop/Engine is required to build and push the images."
}

docker login -u $DockerUser
if ($LASTEXITCODE -ne 0) { throw "Docker Hub login failed." }

foreach ($service in "frontend", "car-service", "booking-service", "contact-service") {
  $image = "docker.io/$DockerUser/carshop-$service`:$Tag"
  docker build --pull --tag $image "services/$service"
  if ($LASTEXITCODE -ne 0) { throw "Build failed for $service." }
  docker push $image
  if ($LASTEXITCODE -ne 0) { throw "Push failed for $service." }
}

Write-Host "Published all images with tag $Tag. Deploy with: kubectl apply -f k8s/deploy.yaml"
