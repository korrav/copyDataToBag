#!/bin/bash

dir_di="/home/x/file_of_andrej/data/mad3/data/July" #файл с входными данными МАДа
dir_do="data_of_mad" #здесь будут временно храниться данные
tempfile_i="rename_files_i" #файл исходного списка файлов
tempfile_s="rename_files_s" #файл отсортированного списка файлов
tarfile="mdatas" #файл архива данных МАД
tempdir=`mktemp -d /tmp/rename_dir.XXXXXX`
number=-1 #количество файлов, которое будет обработано; если = -1, то все файлы в каталоге
idMad=2 #идентификатор МАД, в чью рабочую директорию будут направлены данные
dir_bag="/data/MAD/home/root" #папка куда будет пересылаться архивный файл с данными МАД
adBag="x@192.168.1.165" #ip адрес + имя пользователя

while getopts :n:m: opt
do 
	case "$opt" in 
	n) number=$OPTARG;;
	m) idMad=$OPTARG;;
	*) echo "Неизвестный параметр: $opt"
	rm -R $tempdir
	exit 1;;
	esac
done

cd $tempdir
mkdir $dir_do
touch $tempfile_i
touch $tempfile_s
ls -1 $dir_di > $tempfile_i 
sort -t '_' -k 1,1n -k 2n $tempfile_i  > $tempfile_s

count=1
for file in `cat $tempfile_s`
do 
	cp $dir_di/$file  $dir_do/mdata$count	
	if [ $count -ne -1 ] && [ $count -ge $number ]
	then
		break
	fi
	count=$[ $count + 1 ]
done

tar -zcvf $tarfile.tar $dir_do/
rm -R $dir_do/
dir_bag=`echo $dir_bag | sed "s/MAD/MAD$idMad/"`
dest=$adBag:$dir_bag
echo "Папка в БЭГ, в которую будет передан архив с данными МАД: $dest"
scp $tarfile.tar $dest
rm -R $tempdir
exit 0
