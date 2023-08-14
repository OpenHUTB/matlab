function out=getInstalledProducts(productid)












    persistent productNames

    if isempty(productNames)
        versionInfo=ver;
        productNames={versionInfo.Name};
    end

    switch lower(productid)
    case 'productnames'
        out=productNames;
    case 'basecodes'
        out=locConvertProductNamesToBaseCodes(productNames);
    otherwise
        assert(false);
    end

end

function baseCodes=locConvertProductNamesToBaseCodes(productNames)
    import matlab.internal.product.*;
    baseCodes=cell(1,numel(productNames));
    [baseCodes{:}]=deal('');
    for i=1:numel(productNames)
        baseCodes{i}=getBaseCodeFromProductName(productNames{i});
    end
end
