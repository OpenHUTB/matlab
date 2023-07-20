function endOfCompileCallback(modelName,isModelRef,varargin)%#ok<INUSL> 




    id='SimulinkDiscreteEvent:MatlabEventSystem:DefaultOutputConnection';
    prefName=['Warnings',strrep(id,':','')];
    prefName=prefName(1:63);
    warningStateAtStart=soc.internal.getPreference(prefName);

    if~isModelRef&&ismember(warningStateAtStart,{'on','off'})
        warning(warningStateAtStart,id);
    end
end
