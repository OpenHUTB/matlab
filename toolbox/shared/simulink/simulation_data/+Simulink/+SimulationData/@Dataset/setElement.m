function this=setElement(this,idx,element,name)












    this.verifyDatasetIsScalar;
    this=copyStorageIfNeededBeforeWrite(this);

    max_idx=this.numElements()+1;
    if~isscalar(idx)
        Simulink.SimulationData.utError('DatasetSetInvalidIdx',max_idx);
    end

    try
        if~this.isDatatypeAllowedInDataset(element)
            Simulink.SimulationData.utError('InvalidDatasetElement');
        end
        if nargin>3
            opt_name={name};
        else
            opt_name=[];
        end

        element=this.convertToTransparentElementIfNeeded(element,opt_name);
        if idx==max_idx
            this.Storage_=this.Storage_.addElements(idx,element);
        else
            this.Storage_=this.Storage_.setElements(idx,element);
        end
    catch me
        throwAsCaller(me);
    end


    if nargout<1
        msg=message(...
        'SimulationData:Objects:DatasetUpdateNoLHS',...
        'setElement');
        warning(msg);
    end
end
