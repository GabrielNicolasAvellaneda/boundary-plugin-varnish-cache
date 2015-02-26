Boundary Varnish Cache Plugin
=============================

The Boundary Varnish Cache plugin collects information on Varnish Cache.

### Prerequisites

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

The plugin requires the [varnishstat](https://www.varnish-cache.org/docs/4.0/reference/varnishstat.html#ref-varnishstat)
command to be available and in the system path.

#### For Boundary Meter V4.0
(to update/download - curl -fsS -d '{"token":"api.<Your API Key Here>"}' -H 'Content-Type: application/json' https://meter.boundary.com/setup_meter > setup_meter.sh && chmod +x setup_meter.sh && ./setup_meter.sh)

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |         |        |      |

#### For Boundary Meter less than V4.0

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |         |   v    |      |

The plugin requires Python 2.6 or later.

### Metrics Collected
The information collected is a subset of what is returned by the
[varnishstat](https://www.varnish-cache.org/docs/4.0/reference/varnishstat.html#ref-varnishstat) command.

#### For All Versions

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

### Plugin Setup

#### For All Versions

None

#### Plugin Configuration Fields


The plugin will, by default, collect metrics from the Varnish instance named after the hostname of the machine it is running on.  You can collect metrics on different instances by configuring one or more instance names.

General operations for plugins are described in [this article](http://premium-support.boundary.com/customer/portal/articles/1635550-plugins---how-to).

#### For Boundary Meter V4.0

|Field Name     |Description                                                 |
|:--------------|:-----------------------------------------------------------|
|Source         |The source to display in the legend for the default intance.|
|PollInterval   |Interval to query the varnishstat                           |
|Items          |Array of instances                                          |
|Instance Name  |For every item in Items this sets the instance name         |

#### For Boundary Meter less than V4.0

|Field Name     |Description                                                 |
|:--------------|:-----------------------------------------------------------|
|Items          |Array of instances                                          |
|Instance Name  |For every item in Items this sets the instance name         |


## Adding the Varnish Cache Plugin to Premium Boundary

1. Login into Boundary Premium
2. Display the settings dialog by clicking on the _settings icon_: ![](src/main/resources/settings_icon.png)
3. Click on the _Plugins_ in the settings dialog.
4. Locate the _varnish_cache_ plugin item and click on the _Install_ button.
5. A confirmation dialog is displayed indicating the plugin was installed successfully, along with the metrics and the dashboards.
6. Click on the _OK_ button to dismiss the dialog.

## Removing the Varnish Cache Plugin from Premium Boundary

1. Login into Boundary Premium
2. Display the settings dialog by clicking on the _settings icon_: ![](src/main/resources/settings_icon.png)
3. Click on the _Plugins_ in the settings dialog which lists the installed plugins.
4. Locate the _varnish_cache_ plugin and click on the item, which then displays the uninstall dialog.
5. Click on the _Uninstall_ button which displays a confirmation dialog along with the details on what metrics and dashboards will be removed.
6. Click on the _Uninstall_ button to perfom the actual uninstall and then click on the _Close_ button to dismiss the dialog.