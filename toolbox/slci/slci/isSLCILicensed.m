function[value,msg]=isSLCILicensed(operation)

    if nargin>0
        operation=convertStringsToChars(operation);
    end

    value=dig.isProductInstalled('Simulink Code Inspector');
    msg='';
    if(nargin>0)&&strcmpi(operation,'checkout')&&~value
        msg='Failed to checkout SLCI license.';
    end
end