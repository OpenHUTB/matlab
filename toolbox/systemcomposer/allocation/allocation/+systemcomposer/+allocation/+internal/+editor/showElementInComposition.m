function showElementInComposition(allocSetName,elemId)



    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    allocSet=appCatalog.getAllocationSet(allocSetName);
    allocEnd=mf.zero.getModel(allocSet).findElement(elemId);
    if~isempty(allocEnd)
        designElem=allocEnd.getElement();
        systemcomposer.internal.selectElementInComposition(designElem);
    end

end
