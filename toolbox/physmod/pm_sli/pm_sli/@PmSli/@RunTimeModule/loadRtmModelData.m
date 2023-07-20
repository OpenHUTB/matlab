function loadRtmModelData(this,mdl)







    configData=RunTimeModule_config;

    try
        productsString=get_param(mdl.Handle,configData.ProductsUsed.PropertyName);
    catch %#ok<CTCH>
        productsString='';
        productList={};
    end

    try
        modelTopologyChecksum=str2double(get_param(mdl.Handle,configData.ModelTopologyChecksum.PropertyName));
    catch %#ok<CTCH>
        modelTopologyChecksum='';
    end

    try
        modelParameterChecksum=str2double(get_param(mdl.Handle,configData.ModelParameterChecksum.PropertyName));
    catch %#ok<CTCH>
        modelParameterChecksum='';
    end

    if~isempty(productsString)
        if iscell(productsString)
            productString=productsString{1};
            for idx=2:numel(productsString)
                productString=sprintf('%s%s%s',productString,configData.ProductSeparator,productsString{idx});
            end
        else
            productString=productsString;
        end
        productList=textscan(productString,'%s','Delimiter',configData.ProductSeparator);
        productList=productList{:};



        productList=updateProducts(productList);

    end

    this.modelRegistry.setModelRtmData(mdl,modelTopologyChecksum,modelParameterChecksum,productList);



