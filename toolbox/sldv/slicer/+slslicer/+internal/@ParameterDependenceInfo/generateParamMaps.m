










function[paramToParamMap,paramDirectUsersMap,paramVarUsageMap,paramsAffectedByParamMap,directUsersParamMap,indirectUsersParamMap,indirectParams]=generateParamMaps(varUsage)
    import slslicer.internal.ParameterDependenceInfo.*;

    paramToParamMap=containers.Map;
    paramDirectUsersMap=containers.Map;
    paramVarUsageMap=containers.Map;
    paramsAffectedByParamMap=containers.Map;
    directUsersParamMap=containers.Map;
    indirectUsersParamMap=containers.Map;


    paramAffected=[];


    for i=1:length(varUsage)


        usageDetails=varUsage(i).DirectUsageDetails;
        paramAffectedKey={};
        paramUsers={};


        paramKey=getParamMapKey(varUsage(i));
        for idx=1:length(usageDetails)
            if~strcmp(usageDetails(idx).UsageType,'Block')
                continue;
            end


            [isIndirect,workspace]=isIndirectUser(usageDetails(idx).Identifier);
            blockName=Simulink.ID.getSID(usageDetails(idx).Identifier);
            if isIndirect



                for j=1:length(usageDetails(idx).Properties)


                    paramUserInstance.Name=usageDetails(idx).Properties{j};
                    paramUserInstance.SourceType=workspace;
                    paramUserInstance.Source=usageDetails(idx).Identifier;
                    indirectParamKey=getParamMapKey(paramUserInstance);


                    paramUserInstance.key=indirectParamKey;
                    paramAffected=[paramAffected,paramUserInstance];
                    paramAffectedKey=vertcat(paramAffectedKey,indirectParamKey);
                    if isKey(paramsAffectedByParamMap,indirectParamKey)
                        paramsAffecting=paramsAffectedByParamMap(indirectParamKey);
                        paramsAffectedByParamMap(indirectParamKey)=vertcat(paramsAffecting,paramKey);
                    else
                        paramsAffectedByParamMap(indirectParamKey)={paramKey};
                    end
                end
                if isKey(indirectUsersParamMap,blockName)


                    paramsAffecting=indirectUsersParamMap(blockName);
                    indirectUsersParamMap(blockName)=vertcat(paramsAffecting,paramKey);
                else


                    indirectUsersParamMap(blockName)={paramKey};
                end
            else

                paramUsers=vertcat(paramUsers,blockName);
                if isKey(directUsersParamMap,blockName)


                    paramsAffecting=directUsersParamMap(blockName);
                    directUsersParamMap(blockName)=vertcat(paramsAffecting,paramKey);
                else


                    directUsersParamMap(blockName)={paramKey};
                end
            end
        end

        paramToParamMap(paramKey)=paramAffectedKey;
        paramDirectUsersMap(paramKey)=paramUsers;
        paramVarUsageMap(paramKey)=varUsage(i);
    end


    indirectParams=[];
    if~isempty(paramAffected)
        [~,uniqueIndexes]=unique({paramAffected.key});
        indirectParams=paramAffected(uniqueIndexes);
    end
end
