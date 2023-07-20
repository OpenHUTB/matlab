function getProductLicenses(this,products)









    if~this.validatePlatformLicense
        configData=RunTimeModule_config;
        pm_error(configData.Error.NoPlatformProductLicense_msgid);
    end

    unlicensedProducts={};

    testDeniedProducts=PmSli.RunTimeModule.denyProductLicense;




    prodFcn=pm_private('pm_productsindevelopment');
    try
        productsInDevelopment=prodFcn();
    catch develExcp

        clear develExcp;
        productsInDevelopment={};
    end

    products=setdiff(products,productsInDevelopment);

    for idx=1:numel(products)
        theProduct=products{idx};





        if~isempty(theProduct)&&~pmsl_checklicense(theProduct)
            unlicensedProducts{end+1}=theProduct;%#ok<AGROW>
        end
    end

    for aDeniedProduct=testDeniedProducts
        if any(strcmp(products,aDeniedProduct))
            unlicensedProducts{end+1}=aDeniedProduct{1};%#ok<AGROW>
        end
    end

    if~isempty(unlicensedProducts)

        configData=RunTimeModule_config;

        unlicensedProducts=sort(unique(unlicensedProducts));
        unlicensedNames=pmsl_getproductname(unlicensedProducts);

        productList=sprintf('%s\n',unlicensedNames{:});

        platformProduct=pmsl_defaultproduct;

        if any(strcmp(unlicensedProducts,platformProduct))
            pm_error(configData.Error.NoPlatformProductLicense_msgid);
        else
            pm_error(configData.Error.UnlicensedProducts_templ_msgid,productList);
        end

    end





