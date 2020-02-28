# hdd-spindown.sh

使用hdparm和内核diskstats的自动磁盘待机工具

## 摘要

**hdd-spindown.sh** 是一个相当简单的Bash脚本，对不支持通过固件进行基于超时的降速的驱动器启用自动磁盘待机
(例如 `hdparm` 的 `-S` 参数).


## 用法，要求

**hdd-spindown.sh** 最好通过systemd运行，使用systemd提供的service单元。
为了启用它，只需发出

    $ systemctl enable hdd-spindown.service

并修改配置文件 `/etc/hdd-spindown.rc` 去满足您的需求.

除* coreutils *外，还需要以下内容：
 * **smartctl:** 用于检测驱动器状态和SMART自检
 * **hdparm** 用于实际启动驱动器待机
 * **grep** 用于实用程序输出解析

以下是可选的，具体取决于所使用的功能：
 * **logger** 如果启用了syslog接口
 * **ping** 如果启用主机监视


## 配置

**hdd-spindown.sh** 使用简单的shell风格配置文件来设置要监视的磁盘。一个例子可能看起来像这样：

    # configuration file for hdd-spindown.sh
    
    CONF_INT=300
    
    CONF_DEV=( "ata-WDC_WD50EFRX-68MYMN1_WD-WX31DA43KKCY|5400" \
               "ata-WDC_WD50EFRX-68MYMN1_WD-WX81DA4HNEH5|5400" \
               "ata-WDC_WD20EARS-00MVWB0_WD-WCAZA5755786|5400" \
               "ata-WDC_WD20EARS-00MVWB0_WD-WMAZA3570471|5400" )
  
“ CONF_INT”指定监视间隔（以秒为单位），
“ CONF_DEV”是要监视的设备列表，以及它们的超时值（以秒为单位），
以管道符号“ |”分隔。

请注意，可以使用设备的ID（如图所示）或设备名称（例如'sda'）来指定设备。 
可以省略interval选项，该选项将默认间隔设置为5分钟。

有关选项的完整列表，请参见示例 `hdd-spindown.rc`.


## License

该软件根据MIT许可条款发布，请参阅文件
*LICENSE*.
