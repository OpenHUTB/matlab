function result=getMFunctionSIDs(modelH)



    result={};
    if~rmisf.isStateflowLoaded()
        return;
    end
    if ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end
    modelH=bdroot(modelH);
    if~rmidata.bdHasExternalData(modelH)
        return;
    end
    modelObj=get_param(modelH,'Object');
    mlItems=find(modelObj,'-isa','Stateflow.EMChart',...
    '-or','-isa','Stateflow.EMFunction');%#ok<GTARG>
    if isempty(mlItems)
        return;
    end
    result=cell(size(mlItems));
    for i=1:length(mlItems)
        result{i}=Simulink.ID.getSID(mlItems(i));
    end
end

