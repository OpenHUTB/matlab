function hisl_0017




    rec=getNewCheckObject('mathworks.hism.hisl_0017',false,@hCheckAlgo,'PostCompile');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function Violations=hCheckAlgo(system)
    Violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    relBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','RelationalOperator');
    relBlocks=mdladvObj.filterResultWithExclusion(relBlocks);

    for i=1:length(relBlocks)
        portTypes=get_param(relBlocks{i},'CompiledPortDataTypes');
        if isempty(portTypes)
            continue;
        end
        inputType=portTypes.Inport;
        outputType=portTypes.Outport;

        inputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,inputType);
        outputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,outputType);


        if(length(inputType)==2)&&~strcmp(inputType{1},inputType{2})
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',relBlocks{i});
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0017_rec_action1');
            Violations=[Violations;tempObj];%#ok<AGROW>
        end

        if~strcmp(outputType,'boolean')
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',relBlocks{i});
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0017_rec_action2');
            Violations=[Violations;tempObj];%#ok<AGROW>
        end
    end


end
