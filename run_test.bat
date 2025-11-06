@echo off
setlocal
if not exist logs mkdir logs
echo Starting tests > logs\test_run.log

where mvn >nul 2>&1
if %ERRORLEVEL%==0 (
	echo Found mvn, running tests locally... >> logs\test_run.log
	mvn -q test >> logs\test_run.log 2>&1
	if %ERRORLEVEL%==0 (
		echo Tests finished (mvn) >> logs\test_run.log
		echo Tests finished
		exit /b 0
	) else (
		echo mvn test failed, see logs\test_run.log for details >> logs\test_run.log
		echo mvn test failed. Check logs\test_run.log
		exit /b 1
	)
) else (
	echo mvn not found on PATH. Attempting to use Docker if available... >> logs\test_run.log
	where docker >nul 2>&1
	if %ERRORLEVEL%==0 (
		echo Found Docker, running tests inside Maven Docker image... >> logs\test_run.log
		docker run --rm -v "%CD%":/workspace -w /workspace maven:3.8.8-openjdk-11 mvn -q test >> logs\test_run.log 2>&1
		if %ERRORLEVEL%==0 (
			echo Tests finished (docker) >> logs\test_run.log
			echo Tests finished (docker)
			exit /b 0
		) else (
			echo Docker-based mvn test failed, see logs\test_run.log >> logs\test_run.log
			echo Docker-based mvn test failed. Check logs\test_run.log
			exit /b 1
		)
	) else (
		echo Neither mvn nor docker found. Please install Maven or Docker. >> logs\test_run.log
		echo Neither mvn nor docker found. Please install Maven or Docker.
		exit /b 1
	)
)

endlocal
