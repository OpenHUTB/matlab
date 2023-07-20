function hisl_0015




    rec=getNewCheckObject('mathworks.hism.hisl_0015',false,@hCheckAlgo,'PostCompile');

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



    mergeBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Merge');
    mergeBlocks=mdladvObj.filterResultWithExclusion(mergeBlocks);

    for i=1:length(mergeBlocks)



        mergeParent=get_param(mergeBlocks{i},'Parent');
        if Advisor.Utils.isSFChart(mergeParent)
            continue
        end

        if~ModelAdvisor.Common.isMergeConnectedToCondSubsys(mergeBlocks{i})
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',mergeBlocks{i});
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0015_rec_action1');
            Violations=[Violations;tempObj];%#ok<AGROW> 
        end


        if strcmp(get_param(mergeBlocks{i},'AllowUnequalInputPortWidths'),'on')
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',mergeBlocks{i});
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0015_rec_action2');
            Violations=[Violations;tempObj];%#ok<AGROW>
        end
    end





    msgStruct=slprivate('slanalyze_outport',bdroot(system));
    if ismember('OutportErrorMergedButResetWhenDisabled',fieldnames(msgStruct))
        outports=msgStruct.OutportErrorMergedButResetWhenDisabled.Objects;
        for j=1:length(outports)
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',outports(j));
            tempObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0015_warn3');
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0015_rec_action3');
            Violations=[Violations;tempObj];%#ok<AGROW>
        end
    end

end
