#! /bin/sh

#判断网络是否连通
echo '检测网络状态并同步时间'
sleep 10
for i in `seq 15`; do
	ntpdate 202.108.6.95 cn.ntp.org.cn
	if [ $? == 1 ]; then
		sleep 2
	else
		echo '同步时间成功'
		break
	fi
done

#定义下载目录
path='/www/hosts'
cd $path
echo "当前下载目录 $path"

#定义下载远端目录
rhcloud='https://blog-mingchan.rhcloud.com/mirror/hosts/hosts'
sinapp='http://googlehosts-hostsfiles.stor.sinaapp.com/hosts'
github='https://raw.githubusercontent.com/racaljk/hosts/master/hosts'

#下载部分
echo '尝试从rhcloud镜像中获取'
for i in `seq 3`; do
	wget --no-check-certificate -N $rhcloud -o outlog #下载并保存记录到outlog
	stage=`grep -c 'not retrieving' outlog` #1.16版本兼容 无304 而是not retrieving
	if [ $stage == 0 ]; then
		stage=`grep -c '200' outlog`
		if [ $stage == 0 ]; then
			echo "获取失败第 $i 次"
			sleep 5
		else
			echo '从rhcloud中获取成功'
			echo '# Response: 200[rhcloud Updated]'>log
			break
		fi
	else
		echo '从rhcloud中获取成功'
		echo '# Response: 304[rhcloud NoUpdated]'>log
		break
	fi
done

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