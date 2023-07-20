



function[value,msg]=isFixedPointDesignerLicensed(~)
    value=dig.isProductInstalled('Fixed-Point Designer');
    msg='';
end