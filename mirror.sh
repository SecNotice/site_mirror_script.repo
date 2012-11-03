#!/bin/bash

FETCH="wget --mirror -K -p -E "		# команда для загрузки сайта
CUR_DATE="date +'%Y.%m.%d_%H.%M'"

# печатает список модифицированных файлов
function get_modified_files()
{
	git diff --name-only HEAD > /tmp/mirror_mod_files
	res=`cat /tmp/mirror_mod_files`
	rm /tmp/mirror_mod_files
	echo $res
}

# печатает список добавленных файлов
function get_untracked_files()
{
	res=`git ls-files --other --exclude-standard`
	echo $res
}

# коммитим файлы
function commit_files()
{
	git add $(git ls-files -o --exclude-standard)
	git commit -a -m "`$CUR_DATE`"
}

# печатает логи
function get_log()
{
	echo "\n============ `$CUR_DATE` ============"
	echo "\nИзменённые:"
	echo "\n$MOD"
	echo "\nНовые:"
	echo "\n$NEW"
}

# скачивает сайт, заливает в репозиторий, пишет логи
function main()
{
	pushd $2

	$FETCH $1					# скачиваем сайт
	MOD=$(get_modified_files)
	NEW=$(get_untracked_files)

	LOG=$(get_log)

	$commit_files

	popd

	echo -e $LOG >> log # записываем лог
}

# основной цикл
cat $1 | while IFS= read -r line
do
	A=( $line )
	main ${A[0]} ${A[1]}
done
