SET mapred.input.dir.recursive=true;
SET hive.mapred.supports.subdirectories=true;
SET hive.groupby.orderby.position.alias=true;

DROP TABLE IF EXISTS raw_logs;
CREATE EXTERNAL TABLE raw_logs (
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
LOCATION 's3://gu-anly502/ps05/forensicswiki/2012/';
--LOCATION 's3://gu-anly502/ps05/forensicswiki/2012/12/';

DROP TABLE IF EXISTS agent_logs;
create temporary table agent_logs (
  date  timestamp,
  agent string,
  os    string,
  bot   boolean
);

-- YOUR CODE GOES HERE

insert overwrite table agent_logs
  select from_unixtime(unix_timestamp(rawdatetime, "[dd/MMM/yyyy:HH:mm:ss Z]")),
         agent,
         size,
         case 
           WHEN lower(agent) LIKE '%bot%' THEN TRUE
           ELSE FALSE
         END
  from raw_logs;
-- Section #1:

SELECT * FROM agent_logs limit 3;

-- Section #2: Provide 5 agents for which the OS could not be classified that are bots

select * from agent_logs where bot limit 5;

-- Section #3: Provide 5 agents for which the OS could not be classified that are not bots.

select * from agent_logs where not bot limit 5;


