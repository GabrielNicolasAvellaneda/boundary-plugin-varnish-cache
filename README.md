Boundary Varnish Cache Plugin
=============================

The Boundary Varnish Cache plugin collects information on Varnish Cache.

### Prerequisites

#### Supported OS

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

#### For Boundary Meter versions v4.2 or greater

- To install new meter go to Settings->Installation or [see instructons](https://help.boundary.com/hc/en-us/sections/200634331-Installation). 
- To upgrade the meter to the latest version - [see instructons](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter). 

#### For Boundary Meter less than v4.2

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |         |   v    |      |

The plugin requires Python 2.6 or later.

### Plugin Setup

The plugin requires the [varnishstat](https://www.varnish-cache.org/docs/4.0/reference/varnishstat.html#ref-varnishstat) command to be available and in the system path.

### Plugin Configuration Fields

The plugin will, by default, collect metrics from the Varnish instance named after the hostname of the machine it is running on.  You can collect metrics on different instances by configuring one or more instance names.

General operations for plugins are described in [this article](http://premium-support.boundary.com/customer/portal/articles/1635550-plugins---how-to).

#### For Boundary Meter v4.2

|Field Name     |Description                                                 |
|:--------------|:-----------------------------------------------------------|
|Source         |The source to display in the legend for the default intance.|
|PollInterval   |Interval to query the varnishstat                           |
|Items          |Array of instances                                          |
|Instance Name  |For every item in Items this sets the instance name         |

#### For Boundary Meter less than v4.2

|Field Name     |Description                                                 |
|:--------------|:-----------------------------------------------------------|
|Items          |Array of instances                                          |
|Instance Name  |For every item in Items this sets the instance name         |

### Metrics Collected

The information collected is a subset of what is returned by the [varnishstat](https://www.varnish-cache.org/docs/4.0/reference/varnishstat.html#ref-varnishstat) command.

|Metric Name                    |Description  |
|:------------------------------|:------------|
|Varnish Cache Accept Fail      |             |
|Varnish Cache Backend Busy     |             |
|Varnish Cache Backend Conn     |             |
|Varnish Cache Backend Fail     |             |
|Varnish Cache Backend Recycle  |             |
|Varnish Cache Backend Req      |             |
|Varnish Cache Backend Retry    |             |
|Varnish Cache Backend Reuse    |             |
|Varnish Cache Backend Toolate  |             |
|Varnish Cache Backend Unhealthy|             |
|Varnish Cache Cache Hit        |             |
|Varnish Cache Cache Hitpass    |             |
|Varnish Cache Cache Miss       |             |
|Varnish Cache Client Conn      |             |
|Varnish Cache Client Drop      |             |
|Varnish Cache Client Drop Late |             |
|Varnish Cache Client Req       |             |
|Varnish Cache Fetch 1xx        |             |
|Varnish Cache Fetch 204        |             |
|Varnish Cache Fetch 304        |             |
|Varnish Cache Fetch Failed     |             |
|Varnish Cache Fetch Head       |             |
|Varnish Cache Losthdr          |             |
|Varnish Cache S Bodybytes      |             |
|Varnish Cache S Fetch          |             |
|Varnish Cache S Hdrbytes       |             |
|Varnish Cache S Pass           |             |
|Varnish Cache S Pipe           |             |
|Varnish Cache S Req            |             |
|Varnish Cache S Sess           |             |

### Dashboards

Varnish Cache Summary

### References

None
