



function[value,msg]=isSerDesLicensed(~)
    value=dig.isProductInstalled('SerDes Toolbox');
    msg='';
end