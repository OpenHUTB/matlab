



function[value,msg]=isSimulinkCodeInspectorLicensed(~)
    value=dig.isProductInstalled('Simulink Code Inspector');
    msg='';
end