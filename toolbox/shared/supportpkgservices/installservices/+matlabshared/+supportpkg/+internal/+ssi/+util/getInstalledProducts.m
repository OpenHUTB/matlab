function out=getInstalledProducts(productid)

    validateattributes(productid,{'char'},{'nonempty'},'getInstalledProducts','productid',1);

    persistent productNames

    if isempty(productNames)
        versionInfo=ver;
        productNames={versionInfo.Name};
    end

    switch lower(productid)
    case 'productnames'
        out=productNames;
    case 'basecodes'
        out=convertProductNamesToBaseCodes(productNames);
    otherwise
        assert(false,'Unknown option provided. Please specify either "productnames" or "basecodes"');
    end

end


function baseCodes=convertProductNamesToBaseCodes(prodNames)
    baseCodes={};
    for i=1:numel(prodNames)
        currentBaseCode=matlab.internal.product.getBaseCodeFromProductName(prodNames{i});
        if~isempty(currentBaseCode)
            baseCodes{end+1}=currentBaseCode;
        end
    end

end
