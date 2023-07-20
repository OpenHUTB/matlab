function out=isProductInstalled(productName)





    assert(~isempty(productName),...
    message('hwconnectinstaller:setup:InvalidMathWorksProductName',...
    productName).getString());

    out=locIsProductInstalled(productName)&&locIsProductLicensed(productName);

end

function isInstalled=locIsProductInstalled(productName)



    verInfo=ver;
    productNames=string({verInfo.Name});
    isInstalled=any(productNames.matches(productName));

end

function isLicensed=locIsProductLicensed(productName)



    baseCode=matlab.internal.product.getBaseCodeFromProductName(productName);
    isLicensed=matlab.internal.licensing.isProductLicensed(baseCode);

end
