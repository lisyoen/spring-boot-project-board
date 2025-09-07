# System Rules
- 모든 출력 메시지는 **한국어**로 작성한다.
- 기술 용어(Java, Spring Boot, JPA 등)는 원문 그대로 두고, 설명은 한국어로 쓴다.
- 로그/에러/경로/커맨드는 실제 표기 그대로 출력한다.

---

# Shell Rules (Windows PowerShell 5.1 고정)
- 터미널은 **Windows PowerShell 5.1**이다.
- **금지:** `&&`, `||`, 과도한 `;`(한 줄 다중 명령). 필요하면 줄 단위로 분해한다.
- **하위 셸 금지:** `powershell.exe -Command`, `cmd /c` 등. 반드시 **현재 세션**에서 실행한다.
- 경로 이동은 `Set-Location` 또는 `Push-Location`/`Pop-Location` 사용.
- Maven 실행은 **Wrapper 우선**: `.\mvnw.cmd <args>` → 없으면 `mvn <args>`.
- 환경 변수는 `$env:NAME = 'value'` 형식으로 설정.

---

# Enforcement (강제 규칙)
- 위 규칙을 위반하는 명령은 **실행하지 않는다**. 아래 절차로 **SANITIZE(치환)** 후 치환본만 실행한다.
1) 명령 문자열에 `&&`, `||`, 과도한 `;`, 하위 셸 호출이 있는지 검사한다.
2) 위반 발견 시: 실행 중단 → 줄 단위로 분해하고, 필요한 경우 `if ($LASTEXITCODE -eq 0) { ... }` 패턴으로 조건부 연결한다.
3) 실행 전, **치환된 명령을 그대로 에코**한다(감사/디버깅용).

**치환 예시**
- `cd <dir> && <cmd>` →
  ```powershell
  Set-Location "<dir>"
  <cmd>
  ```
- `<a> && <b>` →
  ```powershell
  <a>
  if ($LASTEXITCODE -eq 0) { <b> }
  ```
- `<a>; <b>; <c>` →
  ```powershell
  <a>
  <b>
  <c>
  ```

---

# Preflight (세션 시작 시 1회)
- UTF-8 인코딩 강제(`chcp 65001`, OutputEncoding 설정)
- 현재 경로 출력
- **board-demo 루트 고정**: `pom.xml` 있는 디렉터리로 진입, 실패 시 **즉시 중단**.
- Maven Wrapper가 `.mvn\mvnw.cmd`에 잘못 생성된 경우 제자리로 이동.

---

# Health Check 권고
- 기본 헬스체크는 `GET /actuator/health` 사용을 권장한다.
- swagger-ui, h2-console 점검이 필요하면 **의존성/설정 추가 후** 접근한다.
