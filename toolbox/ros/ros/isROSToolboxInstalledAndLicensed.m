function[value,msg]=isROSToolboxInstalledAndLicensed(~)




    value=dig.isProductInstalled('ROS Toolbox');
    msg='';
end
