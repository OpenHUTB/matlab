function version=getProductVersion(productName)



    persistent allVersions;
    if(isempty(allVersions))

        allVersions=ver;
    end

    charProductName=char(productName);

    for prodIndex=1:numel(allVersions)
        if(strcmp(charProductName,allVersions(prodIndex).Name))
            version=[allVersions(prodIndex).Version,' ',allVersions(prodIndex).Release];
            return;
        end
    end

    error('report:ProductNotFound',productName);

end
