function data=getData(obj)
    switch(obj.Type)
    case{ModelAdvisor.ResultDetailType.SID,...
        ModelAdvisor.ResultDetailType.Signal,...
        ModelAdvisor.ResultDetailType.String,...
        ModelAdvisor.ResultDetailType.RootLevelStateflowData,...
        ModelAdvisor.ResultDetailType.SimulinkVariableUsage,...
        ModelAdvisor.ResultDetailType.Group}
        data=obj.Data;
    case ModelAdvisor.ResultDetailType.ConfigurationParameter
        data=obj.DetailedInfo.ModelName;
    case ModelAdvisor.ResultDetailType.BlockParameter
        data=obj.DetailedInfo.Block;
    case ModelAdvisor.ResultDetailType.Mfile
        data=obj.DetailedInfo.FileName;
    case{ModelAdvisor.ResultDetailType.Constraint,...
        ModelAdvisor.ResultDetailType.Custom}
        data=obj.CustomData;
    otherwise
        data=[];
    end
end
