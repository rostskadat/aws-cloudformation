# A Analytics platform for the masses

## Description

These stack create an Analytics toolchain based on 
1. [Logstash](https://www.elastic.co/products/logstash)
2. [ElasticSerach](https://www.elastic.co/products/elasticsearch)
3. [Kibana](https://www.elastic.co/products/kibana)
4. [Splunk](https://www.splunk.com/)

All services are configured for Fault Tolerance (but not High Availability). It means that if an instance of one of the services happen to fail, another one will be immediately spun up.

Further, all the services are configured to:
1. Send Health Notification Alert to a predefined email in case of an AutoScaling event.
2. Install Security packages on an hourly basis.
3. Install Update on a daily basis.
4. Periodically run the [AWS Inspector](https://aws.amazon.com/inspector/) Agent to assess the Instance for vulnerability. It will try automatically remediate the CVE.
 
![Analytics infrastructure](./images/analytics.png)