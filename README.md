# **PG_Dump Script**

Script to automatically create backups and send them to Amazon S3.

**Quick start**

Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)


**Before launch** 
1) Configure your AWS S3 access.
2) If your Postgres connection uses a password, you will need to store it in `~/.pgpass`
                                       
                                        `hostname:port:database:username:password`

Each of the first four fields can be a literal value, or *, which matches anything. The password field from the first line that matches the current connection parameters will be used.

Set the following permissions `0600` for the file `~/.pgpass`

                                          `chmod 0600 ~/.pgpass`


3) Open file **pg_dump.cong** and set up your Postgres's credentials and the list of databases to Backup.

**Launch**

1) Run script ./pg_dump.sh

2) Setup cron job. 

                                                 `crontab -e` 

                                       `0 2 * * * /home/user/backup/pg_dump.sh`
