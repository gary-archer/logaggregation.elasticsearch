# logaggregation.elasticsearch

### Overview

* Scripts to enable using Elastic Search with API Logs on different software platforms
* For Developer PC configuration see the [Local Elastic Search Setup](https://authguidance.com/2019/07/19/log-aggregation-setup) page
* For Deployed configuration see the [Cloud Elastic Search Setup](https://authguidance.com/2020/08/11/cloud-elastic-search-setup/) page

### Elastic Search Setup

* A custom schema for API logs is defined and used to create an Elastic Search Index
* An ingestion pipeline is used to ensure that log entries cannot be duplicated

### Kibana Queries

* We use the Kibana console to issue queries against our custom schema

### Filebeat Setup

* Runs on a Developer PC to ship API JSON log files to the Local Elastic Search instance

### Functionbeat Setup

* Runs in AWS to ship Cloudwatch API JSON logs to a Cloud Elastic Search instance

### Running Components as Services

* Developer PC components are configured as background services that run permanently
* This works on all of Windows, Mac OS and Linux
