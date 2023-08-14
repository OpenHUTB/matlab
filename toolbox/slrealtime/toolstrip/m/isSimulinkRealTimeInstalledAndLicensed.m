



function[value,msg]=isSimulinkRealTimeInstalledAndLicensed(~)
    value=dig.isProductInstalled('Simulink Real-Time');
    msg='';
end
