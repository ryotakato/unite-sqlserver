: <<EOF
@echo off
goto Windows

EOF
batPath=${0//\//\\\\}
exec cmd //c "${batPath/\\\\c\\\\/c:\\\\}" $*

:Windows
setlocal

pushd %~dp0

rem ������u������
SET SERVERPC=%1
SET USERNAME=%2
SET PASSWORD=%3
SET DBNAME=%4


if not "%DBNAME%" == "" (
  rem �e�[�u���ꗗ���擾 �w�b�_�[�Ȃ��ADB���Ȃǂ͈����w��
  sqlcmd -S %SERVERPC% -U %USERNAME% -P %PASSWORD% -d %DBNAME% -h -1 -i TBL_INFO.sql
) else (
  echo ERROR : please input db name
)

popd

endlocal