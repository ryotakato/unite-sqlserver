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
SET TBLNAME=%5


if not "%TBLNAME%" == "" (
  rem �J�����ꗗ���擾 �w�b�_�[�Ȃ��ATBL���Ȃǂ͈����w��
  sqlcmd -S %SERVERPC% -U %USERNAME% -P %PASSWORD% -d %DBNAME% -Y 30 -v TBL=%TBLNAME% -i COLUMN_INFO.sql
) else (
  echo ERROR : please input table name
)

popd

endlocal