function obj=loc_handle_slVarUsage(obj,data)
    obj.Data=data.Name;
    persistent model;
    if isempty(model)
        model=mf.zero.Model;
    end
    resultFactory=ModelAdvisor.ResultDetailFactory(model);
    dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.SimulinkVariableUsage);
    dataObj.SlVarSource=data.Source;
    if isstruct(data)&&~isfield(data,'SourceType')
        dataObj.SlVarSourceType='unknown source';
    else
        dataObj.SlVarSourceType=data.SourceType;
    end
    obj.DetailedInfo=dataObj;
end

