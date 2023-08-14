function hisl_0063




    rec=getNewCheckObject('mathworks.hism.hisl_0063',false,@hCheckAlgo,'PostCompile');


    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)

    violations=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;

    maxIdLength=get_param(bdroot(system),'MaxIdLength');




    SSBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','SubSystem');
    SSBlocks=mdlAdvObj.filterResultWithExclusion(SSBlocks);

    for i=1:length(SSBlocks)
        if~strcmpi(get_param(SSBlocks{i},'RTWFcnNameOpts'),'User specified')
            continue;
        end

        functionName=get_param(SSBlocks{i},'RTWFcnName');
        if~isempty(functionName)&&length(functionName)>maxIdLength
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',SSBlocks{i});
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0063_warn1',maxIdLength);
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0063_rec_action1',maxIdLength);
            violations=[violations;vObj];%#ok<AGROW>
        end
    end



    simulinkDataTypes={'Simulink.AliasType','Simulink.NumericType',...
    'Simulink.Variant','Simulink.Bus','Simulink.BusElement'};

    simulinkSignalParamTypes={'Simulink.Signal','Simulink.Parameter'};
    storageClasses={'ExportedGlobal','ImportedExtern','ImportedExternPointer','Custom'};

    allVars=Advisor.Utils.Simulink.findVars(system,inputParams{1}.Value,inputParams{2}.Value);

    for i=1:length(allVars)
        if strcmp(allVars(i).SourceType,'model workspace')
            mdlws=get_param(bdroot(system),'ModelWorkspace');
            var=mdlws.getVariable(allVars(i).Name);
        else

            try
                var=evalinGlobalScope(bdroot(system),allVars(i).Name);
            catch
                var=[];
            end
        end

        if~isempty(var)

            varType=class(var);


            if ismember(varType,simulinkDataTypes)&&length(allVars(i).Name)>maxIdLength
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',allVars(i));
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0063_warn2',maxIdLength);
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0063_rec_action2',maxIdLength);
                violations=[violations;vObj];%#ok<AGROW>
            end
            if isa(var,'Simulink.Bus')
                for j=1:length(var.Elements)
                    if length(var.Elements(j).Name)>maxIdLength
                        dataObj.Source=allVars(i).Source;
                        dataObj.SourceType=allVars(i).SourceType;
                        dataObj.Name=[allVars(i).Name,'.',var.Elements(j).Name];

                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SimulinkVariableUsage',dataObj);
                        vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0063_warn2',maxIdLength);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0063_rec_action2',maxIdLength);
                        violations=[violations;vObj];%#ok<AGROW>
                    end
                end
            end

            if ismember(varType,simulinkSignalParamTypes)
                if ismember(var.CoderInfo.StorageClass,storageClasses)&&length(allVars(i).Name)>maxIdLength
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',allVars(i));
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0063_warn2',maxIdLength);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0063_rec_action2',maxIdLength);
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end
        end
    end

    allVarsWithEnum=Advisor.Utils.Simulink.findVars(system,inputParams{1}.Value,inputParams{2}.Value,'IncludeEnumTypes',true);
    enumVars=setdiff(allVarsWithEnum,allVars);
    for i=1:numel(enumVars)
        if length(enumVars(i).Name)>maxIdLength
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',enumVars(i));
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0063_warn2',maxIdLength);
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0063_rec_action2',maxIdLength);
            violations=[violations;vObj];%#ok<AGROW>
        end
    end

end
