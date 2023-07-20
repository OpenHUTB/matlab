function[value,msg]=isSimulinkDesignOptimizationLicensed(~)









    value=dig.isProductInstalled('Simulink Design Optimization');

    value=value&&sldodialogs.isSimulinkDesignOptimizationAppAvailable();
    msg='';
end
