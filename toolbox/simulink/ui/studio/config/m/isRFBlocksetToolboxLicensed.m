



function[value,msg]=isRFBlocksetToolboxLicensed(~)
    value=dig.isProductInstalled('RF Blockset');
    msg='';
end