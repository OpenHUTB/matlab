function enableIfCoder(~,action)




    areCodersInstalled=dig.isProductInstalled('Simulink Coder')&&...
    dig.isProductInstalled('Embedded Coder');
    action.enabled=areCodersInstalled;