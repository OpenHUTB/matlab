



function[value,msg]=isInstalledAndLicensed(~)
    value=dig.isProductInstalled('AUTOSAR Blockset');
    msg='';
end
