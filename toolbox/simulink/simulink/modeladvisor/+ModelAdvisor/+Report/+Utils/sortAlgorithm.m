function value=sortAlgorithm(sortMethod,elementObj,sortCriteria,method)
    compareString='';
    switch sortMethod
    case 'RecommendedAction'
        compareString=[elementObj.Description,elementObj.Title,elementObj.Information,elementObj.Status,elementObj.RecAction];
    case 'Subsystem'
        if elementObj.Type==ModelAdvisor.ResultDetailType.SID
            compareString=Simulink.ID.getParent(elementObj.Data);
        elseif elementObj.Type==ModelAdvisor.ResultDetailType.Signal
            object=get_param(elementObj.Data,'Object');
            compareString=object.Parent;
        elseif elementObj.Type==ModelAdvisor.ResultDetailType.RootLevelStateflowData
            compareString=elementObj.DetailedInfo.ModelName;
        end
    case 'Block'
        switch elementObj.Type
        case ModelAdvisor.ResultDetailType.RootLevelStateflowData
            compareString=[elementObj.DetailedInfo.ModelName,elementObj.Data];
        otherwise
            compareString=elementObj.Data;
        end
    otherwise
    end
    switch method
    case 'compare'
        if strcmp(compareString,sortCriteria)
            value=true;
        else
            value=false;
        end
    case 'addIntoCriteria'
        value=compareString;
    end
end
