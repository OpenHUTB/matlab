function hisl_0018




    rec=getNewCheckObject('mathworks.hism.hisl_0018',false,@hCheckAlgo,'PostCompile');

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

function violations=hCheckAlgo(system)

    violations=[];

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;



    relBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Logic');
    relBlocks=mdlAdvObj.filterResultWithExclusion(relBlocks);


    for i=1:length(relBlocks)
        portTypes=get_param(relBlocks{i},'CompiledPortDataTypes');
        if isempty(portTypes)
            continue;
        end

        inputType=portTypes.Inport;
        outputType=portTypes.Outport;

        inputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,inputType);
        outputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,outputType);

        if~all(strcmp(inputType,'boolean'))
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',relBlocks{i});
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0018_rec_action1');
            violations=[violations,tempFailObj];%#ok<AGROW>
        end

        if~strcmp(outputType,'boolean')
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',relBlocks{i});
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0018_rec_action2');
            violations=[violations,tempFailObj];%#ok<AGROW>
        end
    end
end
