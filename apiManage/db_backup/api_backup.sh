
#!/bin/sh
# Author:zjh
# Date: 2019/1/10
# Description: Daily backup api database (eolinker)

# config database parameters
db_host="common.mysql.test.ysb"
db_port=63306
db_username="zhongjiahong"
db_password="181808Z"
db_name="eolinker"

backup_dir="/opt/web/apiManage/db_backup"

if [ ! -d "$backup_dir" ];then
mkdir "$backup_dir"
fi

today=`date "+%Y%m%d"`

# custom backup filename
filename="eolinker_api_db"

echo "================  begining backup api data  ================="

cd $backup_dir

#log file
log_file="api_backup.log"
log_max_size=$((1024*1024))
if [ ! -e "$log_file" ];then
  #cteate log file
  touch "$log_file"
fi
#clear log file if its size greater than 1M
echo "Check: ls -l $log_file |awk '{print $5}' -gt $log_max_size"
if [ `ls -l $log_file |awk '{print $5}'` -gt $log_max_size ];then
    #clear log file content
    echo > "$log_file"
fi

#backup file
backup_file="${filename}_${today}.sql"
if [ -e "$backup_file" ];then
  rm -f "$backup_file"
fi

# key command : use mysqldump to backup database
mysqldump -h${db_host} -P${db_port} --single-transaction -u${db_username} -p${db_password} ${db_name} > $backup_dir/$backup_file
echo "Runing: mysqldump -h${db_host} -P${db_port} -u${db_username} -p${db_password} ${db_name} > $backup_dir/$backup_file"

finish_date1=`date '+%Y-%m-%d %H:%M:%S'`

echo "The api information database backup successfully completed at ${finish_date1}."

# keep backups for three days only
one_days_ago=`date -d "1 days ago" +%Y%m%d`
two_days_ago=`date -d "2 days ago" +%Y%m%d`

# reverse delete
find $backup_dir -name "*${filename}*.sql"|grep -v "${today}.sql" |grep -v "${one_days_ago}.sql" |grep -v "${two_days_ago}.sql" | xargs -i rm -f {}
echo "Runing: find $backup_dir -name" "*${filename}*.sql" "|grep -v " "${today}.sql" "|grep -v " "${one_days_ago}.sql" "|grep -v " "${two_days_ago}.sql" "| xargs -i rm -f {}"
finish_date2=`date '+%Y-%m-%d %H:%M:%S'`
echo -e "Clear old backup completed at ${finish_date2}.\n"

