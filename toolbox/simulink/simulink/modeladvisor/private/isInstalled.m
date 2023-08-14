function haveIt=isInstalled(featureName)










    persistent licInfo;
    if isempty(licInfo)
        licInfo=connector.internal.getEntitledProducts();
    end
    isLicensed=ismember(lower(featureName),lower(licInfo.entitledProducts));

    if connector.internal.Worker.isMATLABOnline
        isInstalled=true;
    else
        prodName=matlab.internal.product.getProductNameFromFeatureName(featureName);
        if~isempty(prodName)&&prodName~=""
            isInstalled=dig.isProductInstalled(prodName);
        else
            isInstalled=false;
        end
    end
    haveIt=isInstalled&&isLicensed;
end





