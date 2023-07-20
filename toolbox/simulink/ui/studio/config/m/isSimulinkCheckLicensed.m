



function[value,msg]=isSimulinkCheckLicensed(~)
    value=dig.isProductInstalled('Simulink Check');
    msg='';
end