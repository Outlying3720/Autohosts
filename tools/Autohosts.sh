#! /bin/sh
#Last Update 2016/03/04 6:36 PM
#更新日志:
#	[+]时间同步
#	[+]网络检测

#判断网络是否连通
echo '脚本启动,开始检测网络状态'
until [ $? == 0 ]; do
	ping -c 1 baidu.com
done
echo '网络连接成功'

#同步时间
echo "开始同步时间"
ntpclient -s -h 202.120.2.101&

#定义下载目录
path='/www/hosts'
#path='/Users/ii/Downloads/ADBYBY'
cd $path
echo "当前下载目录 $path"

#定义下载远端目录
sinapp='http://googlehosts-hostsfiles.stor.sinaapp.com/hosts'
github='https://raw.githubusercontent.com/racaljk/hosts/master/hosts'

#下载部分
echo '尝试从Sinaapp镜像中获取'
for i in `seq 3`; do
	wget -N $sinapp -o outlog #下载并保存记录到outlog
	stage=`grep -c 'not retrieving' outlog` #1.16版本兼容 无304 而是not retrieving
	if [ $stage == 0 ]; then
		stage=`grep -c '200' outlog`
		if [ $stage == 0 ]; then
			echo "获取失败第 $i 次"
			sleep 5
		else
			echo '从Sinaapp中获取成功'
			echo '# Response: 200[Sinaapp Updated]'>log
			break
		fi
	else
		echo '从Sinaapp中获取成功'
		echo '# Response: 304[Sinaapp NoUpdated]'>log
		break
	fi
done

if [ $stage == 0 ]; then
	echo '从Sinaapp中获取失败'
	echo '尝试从Github中获取'
	for i in `seq 3`; do
		wget --no-check-certificate $github -o outlog -O hosts_new
		if [[ -s hosts_new ]]; then
			echo '从Github中获取成功'
			echo '# Response: 200[Github]'>log
			break
		else
			echo "获取失败第 $i 次"
			sleep 5
		fi
	done
	if [[ -s hosts_new ]]; then
		cp hosts_new hosts
	else
		echo '从Github中获取失败'
	fi
fi

#写日志
echo -n '# Last checked: '>>log
echo `date +%Y-%m-%e_%X`>>log
grep 'Last updated' hosts>>log
