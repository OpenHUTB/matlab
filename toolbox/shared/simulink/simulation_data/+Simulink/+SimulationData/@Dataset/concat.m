function this=concat(this,val)










    if~isa(val,'Simulink.SimulationData.Dataset')
        Simulink.SimulationData.utError('InvalidDatasetConcat');
    end


    if length(this)~=1||length(val)~=1
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end


    if val.numElements()>0
        this=copyStorageIfNeededBeforeWrite(this);
        this.Storage_=this.Storage_.addElements(this.numElements()+1,...
        val.Storage_.getElements(1:val.numElements()));
    end


    if nargout<1
        msg=message(...
        'SimulationData:Objects:DatasetUpdateNoLHS',...
        'concat');
        warning(msg);
    end
end
