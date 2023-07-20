



function[value,msg]=isControlSystemToolboxLicensed(~)
    value=dig.isProductInstalled('Control System Toolbox');
    msg='';
end