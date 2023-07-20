function hisl_0001




    rec=getNewCheckObject('mathworks.hism.hisl_0001',false,@hCheckAlgo,'PostCompile');

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

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    allObjs=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Abs');
    allObjs=mdladvObj.filterResultWithExclusion(allObjs);

    for i=1:numel(allObjs)
        portTypes=get_param(allObjs{i},'CompiledPortDataTypes');
        if isempty(portTypes)
            continue;
        end

        inputType=portTypes.Inport;
        if any(strcmp(inputType,{'boolean','uint8','uint16','uint32'}))
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',allObjs{i});
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0001_rec_action1');
            violations=[violations;tempObj];%#ok<AGROW>
        end

        if any(strcmp(inputType,{'int8','int16','int32'}))&&strcmp(get_param(allObjs{i},'SaturateOnIntegerOverflow'),'off')
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',allObjs{i});
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0001_rec_action2');
            violations=[violations;tempObj];%#ok<AGROW>
        end
    end
end
