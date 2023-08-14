function[value,msg]=isSimulinkControlDesignLicensed(~)









    value=dig.isProductInstalled('Simulink Control Design')&&...
    dig.isProductInstalled('Control System Toolbox');

    value=value&&slctrlguis.util.isSimulinkControlDesignAppAvailable();
    msg='';
end