# PowerShell 스크립트 - Spring Boot 프로젝트 빌드 및 재시작

# 프로젝트 디렉토리로 이동
Set-Location -Path "D:\git\spring-boot-project-board\project-board"

# 1. 기존 빌드 파일 정리
Write-Output "1. 기존 빌드 파일 정리 중..."
if (Test-Path ".\gradlew.bat") {
    Write-Output "   -> gradlew.bat 파일 확인됨"
    try {
        ./gradlew.bat clean > $null 2>&1
    } catch {
        Write-Output "   -> clean 작업 중 오류 발생. 무시하고 계속 진행합니다."
    }
} else {
    Write-Output "   -> gradlew.bat 파일이 존재하지 않습니다. 빌드 중단."
    exit 1
}

# 2. 프로젝트 빌드
Write-Output "2. 프로젝트 빌드 중..."
if (Test-Path ".\gradlew.bat") {
    Write-Output "   -> gradlew.bat 파일 확인됨"
    ./gradlew.bat build -x test
    if ($LASTEXITCODE -ne 0) {
        Write-Output "   -> 빌드 실패. 서버 재시작 중단."
        exit 1
    }
} else {
    Write-Output "   -> gradlew.bat 파일이 존재하지 않습니다. 빌드 중단."
    exit 1
}

# 3. 기존 실행 중인 애플리케이션 종료
Write-Output "3. 8080 포트 사용 프로세스 종료 시도..."
$process = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -First 1
$pidToStop = $null
if ($process -and $process.OwningProcess -and $process.OwningProcess -ne 0) {
    $pidToStop = $process.OwningProcess
    Write-Output "   -> 종료 대상 PID: $pidToStop (PowerShell)"
} elseif ($process -and ($process.OwningProcess -eq 0 -or -not $process.OwningProcess)) {
    # netstat로 재확인
    $netstatLine = netstat -ano | Select-String ":8080" | Select-Object -First 1
    if ($netstatLine) {
        $fields = $netstatLine -split '\s+'
        $pidNetstat = $fields[-1]
        if ($pidNetstat -and $pidNetstat -ne '0') {
            $pidToStop = [int]$pidNetstat
            Write-Output "   -> 종료 대상 PID: $pidToStop (netstat)"
        } else {
            Write-Output "   -> Idle 프로세스(PID 0 또는 null)는 종료하지 않습니다."
        }
    } else {
        Write-Output "   -> 8080 포트 사용 프로세스 없음 (netstat)"
    }
} else {
    Write-Output "   -> 8080 포트 사용 프로세스 없음"
}

if ($pidToStop -and $pidToStop -ne 0) {
    try {
        Stop-Process -Id $pidToStop -Force
        Write-Output "   -> PID $pidToStop 프로세스 종료 완료"
        Start-Sleep -Seconds 5
    } catch {
        Write-Output "   -> PID $pidToStop 종료 실패: $_"
    }
}

# 4. 애플리케이션 재시작
Write-Output "4. 애플리케이션 재시작 중..."
$jarPath = "build/libs/project-board-0.0.1-SNAPSHOT.jar"
if (Test-Path $jarPath) {
    Write-Output "   -> JAR 파일 확인됨"
$serverProcess = Start-Process -FilePath "java" -ArgumentList "-jar", "-Dspring.profiles.active=testdb", $jarPath -WorkingDirectory "D:\git\spring-boot-project-board\project-board" -NoNewWindow -RedirectStandardOutput "app.log" -PassThru
    Write-Output "   -> 서버 PID: $($serverProcess.Id)"
    
    # 서버 시작 확인
    $timeout = 30
    $started = $false
    while ($timeout -gt 0) {
        Start-Sleep -Seconds 1
$portCheck = $false
try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect("localhost", 8080)
    $portCheck = $tcpClient.Connected
    $tcpClient.Close()
} catch {
    $portCheck = $false
}
        if ($portCheck) {
            $started = $true
            break
        }
        $timeout--
    }
    
    if ($started) {
        Write-Output "   -> 서버가 8080 포트에서 성공적으로 시작됨"
    } else {
        Write-Output "   -> 서버 시작 확인 실패. app.log 확인 필요"
        Stop-Process -Id $serverProcess.Id -Force
    }
} else {
    Write-Output "   -> JAR 파일이 존재하지 않습니다. 빌드가 실패했을 수 있습니다."
    exit 1
}
