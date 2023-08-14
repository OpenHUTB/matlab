function jmaab_jc_0659







    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0659');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0659_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0659';
    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0659_tip');
    rec.setLicense({styleguide_license});
    rec.Value=true;

    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportHighlighting=true;

    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils...
    .createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function ElementResults=checkCallBack(system)
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultData=checkAlgo(system);
    [bResultStatus,ElementResults]=Advisor.Utils.getTwoColumnReport...
    ('ModelAdvisor:jmaab:jc_0659',resultData.failedData);
    if resultData.noMergeBlkFlag
        ElementResults.setSubResultStatusText(DAStudio.message...
        ('ModelAdvisor:jmaab:jc_0659_noMergeBlk'));
    end
    mdlAdvObj.setCheckResultStatus(bResultStatus);
end


function resultData=checkAlgo(system)











    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;


    mergeBlocks=find_system(system,'FollowLinks',inputParams{1}.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',inputParams{2}.Value,...
    'BlockType','Merge');
    resultData.failedData=[];
    resultData.noMergeBlkFlag=false;

    if isempty(mergeBlocks)
        resultData.noMergeBlkFlag=true;
    else
        mergeBlocks=mdladvObj.filterResultWithExclusion(mergeBlocks);
        for mergeBLKCount=1:length(mergeBlocks)
            [isCndSubSysFlag,srcBlk]=ModelAdvisor.Common.isMergeConnectedToCondSubsys(mergeBlocks{mergeBLKCount});
            if~isCndSubSysFlag
                resultData.failedData=[resultData.failedData;
                {mergeBlocks{mergeBLKCount},srcBlk}];
            end
        end
    end
end

