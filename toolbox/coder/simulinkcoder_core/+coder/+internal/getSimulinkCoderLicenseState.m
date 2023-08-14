function[result,msg]=getSimulinkCoderLicenseState(~)



    result=dig.isProductInstalled('Simulink Coder');
    msg='';
end


