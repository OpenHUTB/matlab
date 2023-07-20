function allocSet=open(fileName)



    allocSet=systemcomposer.allocation.load(fileName);
    if(~isempty(allocSet))

        appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
        appCatalog.openStudio(false,allocSet.Name);
    end

end

