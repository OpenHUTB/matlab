function jmaab_jc_0623




    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0623');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0623_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0623';
    rec.setCallbackFcn(@checkCallBack,'PostCompile','StyleOne');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0623_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0623_tip')];
    rec.setLicense({styleguide_license});
    rec.Value=false;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function ResultDescription=checkCallBack(system)
    ResultDescription={};
    bResult=true;
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    [FailingMObjs,FailingUObjs]=checkAlgo(system);

    [bSubResult,resultDesc]=MakeListTemplate(FailingMObjs,'jc_0623_mem_block');
    bResult=bResult&&bSubResult;
    ResultDescription{end+1}=resultDesc;

    [bSubResult,resultDesc]=MakeListTemplate(FailingUObjs,'jc_0623_ud_block');
    bResult=bResult&&bSubResult;
    resultDesc.setSubBar(false);
    ResultDescription{end+1}=resultDesc;

    mdladvObj.setCheckResultStatus(bResult);
end

function[bResult,resultDesc]=MakeListTemplate(FailingObjs,msgPrefix)
    bResult=true;
    resultDesc=ModelAdvisor.FormatTemplate('ListTemplate');
    resultDesc.setSubTitle(DAStudio.message(['ModelAdvisor:jmaab:',msgPrefix]));
    resultDesc.setSubBar(true);

    if~isempty(FailingObjs)
        resultDesc.setSubResultStatus('Warn');
        resultDesc.setSubResultStatusText(DAStudio.message(['ModelAdvisor:jmaab:',msgPrefix,'_warn']));
        resultDesc.setListObj(FailingObjs);
        resultDesc.setRecAction(DAStudio.message(['ModelAdvisor:jmaab:',msgPrefix,'_recAction']));
        bResult=bResult&&false;
    else
        resultDesc.setSubResultStatus('Pass');
        resultDesc.setSubResultStatusText(DAStudio.message(['ModelAdvisor:jmaab:',msgPrefix,'_pass']));
        bResult=bResult&&true;
    end
end

function[FailingMObjs,FailingUObjs]=checkAlgo(system)

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;



    memBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Memory');
    memBlocks=mdlAdvObj.filterResultWithExclusion(memBlocks);
    flag=false(1,length(memBlocks));
    for i=1:length(memBlocks)
        block=get_param(memBlocks{i},'Object');
        cST=get_param(block.PortHandles.Inport,'CompiledSampleTime');
        if iscell(cST)
            cST=cell2mat(cST);
        end
        if~(cST(1)==0&&cST(2)==0)
            flag(i)=true;
        end
    end
    FailingMObjs=memBlocks(flag);



    uDBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'regexp','on','FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','UnitDelay|Delay');
    uDBlocks=mdlAdvObj.filterResultWithExclusion(uDBlocks);
    flag=false(1,length(uDBlocks));
    for i=1:length(uDBlocks)
        block=get_param(uDBlocks{i},'Object');
        cST=get_param(block.PortHandles.Inport,'CompiledSampleTime');
        if iscell(cST)
            cST=cell2mat(cST);
        end
        flag(i)=~(cST(1)>0||(cST(1)==-1&&cST(2)<0));
    end
    FailingUObjs=uDBlocks(flag);
end
