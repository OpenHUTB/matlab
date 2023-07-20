classdef ParameterDependenceInfo<handle





    properties(Access=public,Hidden=true)
        paramToParamMap=[];
        paramDirectUsersMap=[];
        paramVarUsageMap=[];
        paramsAffectedByParamMap=[];
        directUsersParamMap=[];
        indirectUsersParamMap=[];
        model=[];
    end

    methods
        function obj=ParameterDependenceInfo(model,parametersToConsider)

            import slslicer.internal.ParameterDependenceInfo.generateParamDataStructures;


            obj.model=model;

            [obj.paramToParamMap,obj.paramDirectUsersMap,obj.paramVarUsageMap,obj.paramsAffectedByParamMap,obj.directUsersParamMap,obj.indirectUsersParamMap]=generateParamDataStructures(model,parametersToConsider);
        end


        blockList=getStartingPointsForParam(obj,varUsage,includeIndirect);


        parameters=getParametersUsedByBlocks(obj,blocks,startingBlock,includeIndirect);


        addParameterToClassScope(obj,parameters);

        function delete(obj)
            obj.paramToParamMap=[];
            obj.paramDirectUsersMap=[];
            obj.paramVarUsageMap=[];
            obj.paramsAffectedByParamMap=[];
            obj.directUsersParamMap=[];
            obj.model=[];
        end
    end

    methods(Static)


        [paramToParamMap,paramDirectUsersMap,paramVarUsageMap,paramsAffectedByParamMap,directUsersParamMap,...
        indirectUsersParamMap,indirectParams]=generateParamMaps(varUsage);

        [paramToParamMap,paramDirectUsersMap,paramVarUsageMap,paramsAffectedByParamMap,directUsersParamMap,...
        indirectUsersParamMap]=generateParamDataStructures(model,parametersToConsider);



        varUsages=getPopulatedVarUsages(model,parametersToConsider);



        [isIndirect,workspace]=isIndirectUser(block);

        function paramMapKey=getParamMapKey(varUsage)

            import slslicer.internal.ParameterDependenceInfo.getActualSource;
            paramName=varUsage.Name;
            paramSourceType=varUsage.SourceType;
            paramSource=getActualSource(varUsage.Source);
            paramMapKey=strcat(paramName,'_',paramSourceType,'_',paramSource);
        end

        function source=getActualSource(paramSource)


            source=paramSource;
            try


                handle=get_param(paramSource,'handle');
                if strcmp(get_param(handle,'type'),'block')&&strcmp(get_param(handle,'BlockType'),'ModelReference')
                    source=get_param(handle,'ModelName');
                end
            catch
            end
        end

        function originalMap=mergeMaps(originalMap,additionalMap)

            keys=additionalMap.keys;
            for idx=1:length(keys)
                additionalValue=additionalMap(keys{idx});
                if isKey(originalMap,keys{idx})
                    originalValue=originalMap(keys{idx});
                    originalMap(keys{idx})=unique(vertcat(originalValue,additionalValue));
                else
                    originalMap(keys{idx})=additionalValue;
                end
            end
        end
    end
end
