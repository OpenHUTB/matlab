function success=getParameterOverrideDetails(obj,simWatcher)




    success=true;

    if(simWatcher.permutationId>0&&~obj.runningOnMRT)
        simWatcher.refreshParameters(simWatcher.permutationId);
        if(~isempty(simWatcher.refreshErrorMSG))
            [errLog{1:length(simWatcher.refreshErrorMSG)}]=deal(true);
            obj.addMessages(simWatcher.refreshErrorMSG,errLog);
            success=false;
            return;
        end





        tmpOverrides=stm.internal.getParameterOverrideDetails(obj.testSettings.parameterOverrides.parameterSetId);
        success=isempty(tmpOverrides.Errors);
        for k=1:length(tmpOverrides.Errors)
            obj.out.messages{end+1}=tmpOverrides.Errors{k};
            obj.out.errorOrLog{end+1}=true;
        end
        if(~success)
            return;
        end
        obj.testSettings.parameterOverrides.OverridesStruct=tmpOverrides.ParameterOverrides;
    end





    if obj.runningOnMRT
        paramStruct=obj.testSettings.parameterOverrides.OverridesStruct;
        [errors,poList]=simWatcher.updateParameterOverrides(paramStruct,obj.runningOnMRT);
        if isempty(errors)
            obj.testSettings.parameterOverrides.OverridesStruct=poList;
        else
            obj.addMessages(errors,num2cell(true(1,length(errors))));
            success=false;
            return;
        end
    end

    currentParameterSetId=obj.testSettings.parameterOverrides.parameterSetId;
    if simWatcher.refreshErrorMSGMap.isKey(currentParameterSetId)
        idx=simWatcher.refreshErrorMSGMap(currentParameterSetId);
        if idx<=length(simWatcher.refreshErrorMSGList)
            tmpMSG=simWatcher.refreshErrorMSGList{idx};
            if~isempty(tmpMSG)
                obj.out.messages=[obj.out.messages,tmpMSG];
                for k=1:length(tmpMSG)
                    obj.out.errorOrLog{end+1}=true;
                end
                success=false;
                return;
            end
        end
    end
end
