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
#	echo "\n============ `$CUR_DATE` ============"
	echo "\nModified:"
	echo "\n$MOD"
	echo "\nNew:"
	echo "\n$NEW"
}

# скачивает сайт, заливает в репозиторий, пишет логи
function main()
{
	LOG_FILE="`pwd`/log"
	URL=$1
	LOC=$2
	
	pushd $LOC

	echo -e "\n============ `$CUR_DATE` ============" >> $LOG_FILE
	echo -e "\n. Start fetching '$URL'" >> $LOG_FILE
	
	$FETCH $1					# скачиваем сайт

	if [ $? != "0" ]
	then
		echo -e "\n- Error while fetching" >> $LOG_FILE
	else
		echo -e "\n+ Fetching successed" >> $LOG_FILE
	fi

	MOD=$(get_modified_files)
	NEW=$(get_untracked_files)

	LOG=$(get_log)

	$commit_files

	popd

	echo -e $LOG >> $LOG_FILE
}

OLD_LANG=$LANG
export LANG="en.EN_UTF-8"

# основной цикл
cat $1 | while IFS= read -r line
do
	A=( $line )
	main ${A[0]} ${A[1]}
done

export LANG="$OLD_LANG"
