function pruneSubCCs(this,products)









    subCCs=this.getSubComponentList;
    for ccInfo=subCCs

        if~strcmp(ccInfo.ProductName,this.getComponentName)&&...
            ~hstrFind(products,ccInfo.LicenseName)&&...
            ~isempty(this.getComponent(ccInfo.ProductName))


            this.detachComponent(ccInfo.ProductName);

        end

    end


    function isPresent=hstrFind(products,compProd)

        isPresent=false;
        for idx=1:length(products)
            isPresent=~isempty(strfind(compProd,products{idx}));
            if isPresent
                break;
            end
        end


