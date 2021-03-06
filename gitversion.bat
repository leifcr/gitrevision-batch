@echo off
@pushd .
SETlocal enabledelayedexpansion
set exit_code=0

IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF DEFINED PROCESSOR_ARCHITEW6432 (
    set git_bin="%ProgramFiles(x86)%\git\bin"
  ) ELSE (
    set git_bin="%ProgramFiles%\git\bin"
  )
) ELSE IF %PROCESSOR_ARCHITECTURE% == AMD64 (
    set git_bin="%ProgramFiles(x86)%\git\bin"
    ) ELSE (
  set git_bin="%ProgramFiles%\git\bin"
)
:: Remove qoutes
SET git_bin=!git_bin:"=!
:: " quote to make Sublime Text happy...

@echo ------------------------------------
@echo    Git version processing
@echo ------------------------------------
:: Preprocessing parameters

:: Preprocessing parameter 1
:1
IF [%1] EQU [] (
  @echo ===-------------------------------------------===----------
  @echo   ERROR: Missing Git repo directory 
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO USAGE
)
:: verify that .git exists within given directory
IF EXIST %1 (
  "!git_bin!\git.exe" describe --tags
  IF %ERRORLEVEL% NEQ 0 (
    @echo ===-------------------------------------------===
    @echo   ERROR: No git repository in given directory.
    @echo ===-------------------------------------------===
    SET exit_code=1
    GOTO FINITO
  )
) ELSE (
  @echo ===-------------------------------------------===
  @echo   ERROR: Missing Git repo directory 
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO USAGE
)

:: Preprocessing parameter 2
:2
IF [%2] EQU [] (
  @echo ===-------------------------------------------===
  @echo   ERROR: Missing Input filename 
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO USAGE
)

:: verify that input file exists
IF NOT EXIST %2 (
  @echo ===-------------------------------------------===
  @echo   ERROR: Input file does not exist
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO FINITO
)

:: Preprocessing parameter 3
:3
IF [%3] EQU [] (
  @echo ===-------------------------------------------===
  @echo   ERROR: Missing Output filename 
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO USAGE
)
:: if output file exists, just warn about it
IF EXIST %3 (
  @echo ===-------------------------------------------===
  @echo   WARN: output file exists... will overwrite!
  @echo ===-------------------------------------------===
)

:: Check that input != output
IF [%3] EQU [%2] (
  @echo ===-------------------------------------------===
  @echo   ERROR: Input and ouput filename is equal.
  @echo ===-------------------------------------------===
  SET exit_code=1
  GOTO FINITO
 )
GOTO PROCESSING

:GO_FOLDER_UP_IF_NOT_ROOT

:PROCESSING
@echo ------------------------------------------------------------------------------------------
@echo - Updating git version
@echo -   Using git repository : %1
@echo -   using input file     : %2
@echo -   output to file       : %3
@echo ------------------------------------------------------------------------------------------


CD /d %1
:: To get latest abbriviated hash from git
:: git log -n 1  --pretty="format:%h"
:: To get current tag
:: git describe --tags
:: git describe --tags --long | sed "s/v\([0-9]*\).*/\1/"'

FOR /F "tokens=1 delims=" %%A in ('"!git_bin!\git.exe" describe --tags --long') do SET current_tag=%%A
::!current_tag! 
FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/\(v[0-9]*\.[0-9]*\.[0-9]*\)-[0-9]*-g.*/\1/"') do SET tag_only=%%A
FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v\([0-9]*\).*/\1/"') do SET major_version=%%A
FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.\([0-9]*\).*/\1/"') do SET minor_version=%%A
FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/"') do SET revision=%%A
FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.[0-9]*\.[0-9]*-\([0-9]*\).*/\1/"') do SET commits_since_tag=%%A
FOR /F "tokens=1 delims=" %%A in ('echo !current_tag! ^| sed "s/v[0-9]*\.[0-9]*\.[0-9]*-[0-9]*-g\(.*\)/\1/"') do SET git_hash=%%A
SET git_hash=!git_hash: =!
FOR /F "tokens=1 delims=" %%A in ('"!git_bin!\git.exe" describe !tag_only! --tags --long') do SET git_tag_complete_with_hash=%%A
FOR /F "tokens=1 delims=" %%A in ('echo !git_tag_complete_with_hash! ^| sed "s/v[0-9]*\.[0-9]*\.[0-9]*-[0-9]*-g\(.*\)/\1/"') do SET git_tag_hash=%%A
SET git_tag_hash=!git_tag_hash: =!

@echo   Tag Only:          !tag_only!
@echo   Current Tag:       !current_tag!
@echo   Major Version:     !major_version!
@echo   Minor Version:     !minor_version!
@echo   Revision:          !revision!
@echo   Commits since tag: !commits_since_tag!
@echo   Git Hash:          !git_hash!
@echo   Git Tag Hash:      !git_tag_hash!

:: Replace parameters in file using sed
popd
sed -e "s/\$MAJOR_VERSION\$/!major_version!/g" -e "s/\$MINOR_VERSION\$/!minor_version!/g" -e "s/\$REVISION\$/!revision!/g" -e "s/\$COMMITS_SINCE_TAG\$/!commits_since_tag!/g" -e "s/\$GIT_TAG_HASH\$/!git_tag_hash!/g" -e "s/\$GIT_HASH\$/!git_hash!/g" <%2 >%3
pushd .

GOTO FINITO

:USAGE
@echo --------------------------------------------------------------------------------------
@echo  usage: gitversion.bat folder_with_git_repo inputfile outputfile
@echo  example: gitversion.bat c:\my_git_repo version_input.h version.h
@echo -
@echo  Important note: This expects tags to be in format: Anything else won't work. 
@echo  v1.0.123 where 1 is major, 0 is minor and 123 is revision
@echo  -
@echo  parameters replaced in input file:
@echo     $MAJOR_VERSION$     - the major version number
@echo     $MINOR_VERSION$     - the minor version number
@echo     $REVISION$          - the revision number
@echo     $COMMITS_SINCE_TAG$ - number of commits since last tag
@echo     $GIT_TAG_HASH$      - git hash for the tag
@echo     $GIT_HASH$          - the current git hash 
@echo                          (will be same as GIT_HASH if the current tag is checked out)
@echo --------------------------------------------------------------------------------------

:FINITO
EndLocal&SET exit_code=!exit_code!
popd
exit /B !exit_code!
