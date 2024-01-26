% 判断机器人操作系统是否安装并授权
function[value,msg]=isROSToolboxInstalledAndLicensed(~)
    value = dig.isProductInstalled('ROS Toolbox');
    msg='';
end
