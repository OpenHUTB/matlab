



function[value,msg]=isAutomatedDrivingSystemToolboxLicensed(~)
    value=dig.isProductInstalled('Automated Driving Toolbox');
    msg='';
end