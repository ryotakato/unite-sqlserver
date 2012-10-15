: <<EOF
@echo off
goto Windows

EOF
batPath=${0//\//\\\\}
exec cmd //c "${batPath/\\\\c\\\\/c:\\\\}" $*

:Windows
setlocal

pushd %~dp0

rem 引数を置き換え
SET SERVERPC=%1
SET USERNAME=%2
SET PASSWORD=%3

rem DB一覧を取得 ヘッダーなし
sqlcmd -S %SERVERPC% -U %USERNAME% -P %PASSWORD% -h -1 -i DB_INFO.sql

popd

endlocal