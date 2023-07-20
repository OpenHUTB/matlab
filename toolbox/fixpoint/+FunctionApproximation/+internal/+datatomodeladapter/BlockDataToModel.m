classdef BlockDataToModel<FunctionApproximation.internal.datatomodeladapter.DataToModel





    methods(Hidden)
        function modelInfo=initializeModelInfo(~)

            modelInfo=FunctionApproximation.internal.datatomodeladapter.ModelInfo();
        end

        function initializeModel(~,modelInfo)

            [~,postFixModelName]=fileparts(tempname);
            modelInfo.ModelName=[modelInfo.ModelNamePrefix,datestr(now,'yyyymmddTHHMMSSFFF'),'_',postFixModelName(1:14)];



            modelHandle=new_system(modelInfo.ModelName);
            modelObject=get_param(modelHandle,'Object');
            modelInfo.ModelObject=modelObject;
            modelInfo.ModelWorkspace=get_param(modelInfo.ModelName,'modelworkspace');
        end

        function copyOriginalBlock(this,modelInfo,blockData)

            add_block(blockData.FullName,getBlockPath(modelInfo));


            copyDependencies(this,modelInfo,blockData)
        end

        function copyDependencies(~,modelInfo,blockData)
            blockDependencyHandler=FunctionApproximation.internal.datatomodeladapter.BlockDependencyHandler();
            allVariables=blockDependencyHandler.getAllVariables(blockData.SID);
            if~isempty(allVariables)
                nVariables=numel(allVariables);
                sourceModelName=Simulink.ID.getModel(blockData.SID);


                baseWorkspaceIndices=false(1,nVariables);
                ddWorkspaceIndices=false(1,nVariables);
                modelWorkspaceIndices=false(1,nVariables);
                maskWorkspaceIndices=false(1,nVariables);
                for iVar=1:nVariables
                    currentVariable=allVariables(iVar);
                    baseWorkspaceIndices(iVar)=getSourceTypeEnum(currentVariable)=="Base";
                    ddWorkspaceIndices(iVar)=getSourceTypeEnum(currentVariable)=="DataDictionary";
                    modelWorkspaceIndices(iVar)=getSourceTypeEnum(currentVariable)=="Model";
                    maskWorkspaceIndices(iVar)=getSourceTypeEnum(currentVariable)=="Mask";
                end


                if any(baseWorkspaceIndices)||any(ddWorkspaceIndices)

                    externalDataAccessor=Simulink.data.DataAccessor.createForExternalData(sourceModelName);
                    builderModelWorkspace=modelInfo.ModelWorkspace;
                    globalWorkspaceVariables=allVariables(baseWorkspaceIndices|ddWorkspaceIndices);
                    for ii=1:numel(globalWorkspaceVariables)
                        variableUsage=globalWorkspaceVariables(ii);
                        variableName=variableUsage.getName;
                        variableId=externalDataAccessor.name2UniqueID(variableName);
                        variableValue=externalDataAccessor.getVariable(variableId);


                        builderModelWorkspace.assignin(variableName,variableValue);
                    end
                end


                if any(modelWorkspaceIndices)
                    modelWorkspaceVariables=allVariables(modelWorkspaceIndices);


                    modelWorkspace=get_param(sourceModelName,'modelworkspace');
                    builderModelWorkspace=modelInfo.ModelWorkspace;


                    variableNames=arrayfun(@(x)getName(x),modelWorkspaceVariables,'UniformOutput',false);



                    blockDependencyHandler.transferModelWorkspaceVariables(variableNames,builderModelWorkspace,modelWorkspace)
                end


                if any(maskWorkspaceIndices)
                    builderModelWorkspace=modelInfo.ModelWorkspace;
                    maskVariables=allVariables(maskWorkspaceIndices);
                    for i=1:numel(maskVariables)
                        if~isequal(maskVariables(i).getSource(),blockData.FullName)







                            sourceMaskVariables=get_param(maskVariables(i).VariableUsage.Source,'MaskWSVariables');
                            variableName=maskVariables(i).getName;
                            loc=strcmp(variableName,{sourceMaskVariables.Name});

                            variableValue=sourceMaskVariables(loc).Value;
                            builderModelWorkspace.assignin(variableName,variableValue);
                        end
                    end
                end


                sourceConfigSetCopy=copy(getActiveConfigSet(sourceModelName));
                attachConfigSet(modelInfo.ModelName,sourceConfigSetCopy,true);


                dirtyOff(modelInfo);
            end

            if FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(blockData.FullName)
                builderModelWorkspace=modelInfo.ModelWorkspace;
                schema=FunctionApproximation.internal.approximationblock.BlockSchema();
                approximationBlockInfo=FunctionApproximation.internal.approximationblock.getApproximationBlockInfoUsingBlock(blockData.FullName);
                problemStructParameter=approximationBlockInfo.MaskObject.getParameter(schema.ProblemStructParameterName);
                problemStruct=jsondecode(problemStructParameter.Value);
                dependentVariables=problemStruct.DependentVariables;
                dependentVariables=convertCharsToStrings(dependentVariables);
                for ii=1:numel(dependentVariables)
                    variableName=char(dependentVariables(ii));
                    try
                        variableValue=slResolve(variableName,blockData.FullName);
                        builderModelWorkspace.assignin(variableName,variableValue);
                    catch err %#ok<NASGU> % for debugging








                    end
                end
            end
        end
    end
end


