DROP TABLE IF EXISTS apache_common_log;

CREATE EXTERNAL TABLE apache_common_log (
  host STRING,
  identity STRING,
  user STRING,
  rawdatetime STRING,
  request STRING,
  status STRING,
  size STRING,
  refer STRING,
  agent STRING
  )
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*) \"([^\"]*)\" \"([^\"]*)\".*",
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s"
)
STORED AS TEXTFILE
LOCATION 's3://gu-anly502/ps05/forensicswiki/2012/12/';

create temporary table clean_logs (
  agent STRING,
  datetime string,
  size BIGINT,
  bot BOOLEAN
);

insert overwrite table clean_logs
  select agent,
         from_unixtime(unix_timestamp(rawdatetime, "[dd/MMM/yyyy:HH:mm:ss Z]")),
         size,
         bot        
  from apache_common_log;

SELECT * FROM clean_logs limit 30;


--72.47.85.98	2012-12-01 08:19:03	/
--69.163.129.236	2012-12-01 08:19:04	/w/extensions/BibTex/bibtex.css
--69.163.129.236	2012-12-01 08:19:04	/w/extensions/BibTex/bibtex.js
