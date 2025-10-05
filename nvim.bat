@echo off
setlocal enabledelayedexpansion

:: ================= PROFILE LIST =================
set PROFILES=Lazy,^
Kickstart,^
AstroNvim,^
Minimal,^
Coding,^
Writing

:: Convert to array and count
set "PROFILE_COUNT=0"
for %%p in (%PROFILES%) do (
    set /A PROFILE_COUNT+=1
    set "PROFILE_!PROFILE_COUNT!=%%p"
)

echo ---- profile !NVIM_PROFILE!
:: Default: first profile
if defined NVIM_PROFILE (
		echo Found profile !NVIM_PROFILE!
	) else (
		set "NVIM_PROFILE=Lazy"
		REM set "NVIM_PROFILE=Kickstart"
		REM set "NVIM_PROFILE=AstroNvim"
		echo No profile set, defaulting to !NVIM_PROFILE!
	)
)

:loop
    echo =================================================
    echo Starting Neovim with profile: !NVIM_PROFILE!
    echo =================================================

    set "NVIM_APPNAME=nvim"
    C:\Apps\TexT\Neovim\bin\nvim.exe %1 %2 %3 %4 %5 %6 %7
    set "EXIT_CODE=%ERRORLEVEL%"

    if %EXIT_CODE% LEQ 0 goto :exit_final
    if %EXIT_CODE% EQU 1 goto :loop
    if %EXIT_CODE% GEQ 10 (
        set /A "TARGET_INDEX=%EXIT_CODE% - 10"
        if !TARGET_INDEX! LEQ !PROFILE_COUNT! (
            if !TARGET_INDEX! GEQ 0 (
				set "pos=0"
				for %%l in (!PROFILES!) do (
					if defined pos (
						if !pos!==!TARGET_INDEX! (
							set "pos="
							set "NVIM_PROFILE=%%l"
							setx NVIM_PROFILE %%l > nul
							goto :loop
						) else (
							set /a "pos+=1"
						)
					)
				)
            )
        )
        echo Invalid profile index: !TARGET_INDEX! ^(must be 1-!PROFILE_COUNT!^)
        goto :exit_final
    )
    goto :exit_final

:exit_final
    echo.
    echo Exiting Neovim Launcher...
    endlocal & set "NVIM_PROFILE=%NVIM_PROFILE%"
	set "NVIM_APPNAME="
    exit /b 0