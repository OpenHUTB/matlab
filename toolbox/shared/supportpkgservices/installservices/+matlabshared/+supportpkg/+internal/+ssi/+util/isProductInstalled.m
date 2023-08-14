function retVal=isProductInstalled(productName)





    validateattributes(productName,{'char'},{'nonempty'},'isProductInstalled','spRoot',1);

    verInfo=ver;
    prodNames=string({verInfo.Name});
    installed=any(prodNames.matches(productName));
    baseCode=matlab.internal.product.getBaseCodeFromProductName(productName);
    licensed=matlab.internal.licensing.isProductLicensed(baseCode);
    retVal=installed&licensed;