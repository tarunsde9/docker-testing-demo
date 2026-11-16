$imageName = "docker-testing-demo:test"
$containerName = "smoke-test-container"

try {
    Write-Host "Building Docker image..."

    docker build -t $imageName .

    if ($LASTEXITCODE -ne 0) {
        throw "Docker image build failed"
    }

    Write-Host "Starting container..."

    docker run -d --name $containerName -p 8080:8080 $imageName

    if ($LASTEXITCODE -ne 0) {
        throw "Container startup failed"
    }

    Write-Host "Waiting for application..."

    Start-Sleep -Seconds 15

    Write-Host "Testing API..."

    $response = Invoke-RestMethod http://localhost:8080/hello

    if ($response -ne "Docker smoke test successful!") {
        throw "API response did not match expected result"
    }

    Write-Host "SMOKE TEST PASSED!" -ForegroundColor Green
}
catch {
    Write-Host "SMOKE TEST FAILED: $_" -ForegroundColor Red
}
finally {
    Write-Host "Cleaning up..."

    docker rm -f $containerName 2>$null
}