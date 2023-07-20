function this=removeElement(this,idx)








    this.verifyDatasetIsScalar;
    this=copyStorageIfNeededBeforeWrite(this);

    try
        if~isempty(idx)

            this.Storage_=this.Storage_.removeElements(idx);
        end
    catch me
        throwAsCaller(me);
    end


    if nargout<1
        msg=message(...
        'SimulationData:Objects:DatasetUpdateNoLHS',...
        'remove');
        warning(msg);
    end
end
