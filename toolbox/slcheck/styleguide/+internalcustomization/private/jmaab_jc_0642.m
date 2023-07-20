function jmaab_jc_0642




    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0642');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0642_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0642';
    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0642_tip');
    rec.setLicense({styleguide_license});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
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

function result=checkCallBack(system)
    [FailingObjs,conditionStatus]=checkAlgo(system);
    result={};
    ft1=ModelAdvisor.FormatTemplate('ListTemplate');
    ft1.setInformation...
    (DAStudio.message('ModelAdvisor:jmaab:jc_0642_tip'));
    ft1.setSubBar(0);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    if~isempty(FailingObjs)
        linkToProdIntDivRoundTo=Advisor.Utils.getHyperlinkToConfigSetParameter(bdroot(system),'ProdIntDivRoundTo');

        ft1.setSubResultStatus('Warn');
        ft1.setSubResultStatusText...
        (DAStudio.message('ModelAdvisor:jmaab:jc_0642_warn'))
        ft1.setListObj(linkToProdIntDivRoundTo);
        ft1.setRecAction...
        (DAStudio.message('ModelAdvisor:jmaab:jc_0642_recAction'));


        ft2=ModelAdvisor.FormatTemplate('ListTemplate');
        ft2.setInformation(DAStudio.message('ModelAdvisor:jmaab:jc_0642_info'));
        ft2.setListObj(FailingObjs);
        ft2.setSubBar(0);

        mdladvObj.setCheckResultStatus(false);
        result{end+1}=ft1;
        result{end+1}=ft2;
    else
        if conditionStatus==1
            ft1.setSubResultStatus('Pass');
            ft1.setSubResultStatusText...
            (DAStudio.message('ModelAdvisor:jmaab:jc_0642_pass1'));
        elseif conditionStatus==2
            ft1.setSubResultStatus('Pass');
            ft1.setSubResultStatusText...
            (DAStudio.message('ModelAdvisor:jmaab:jc_0642_pass2'));
        end
        mdladvObj.setCheckResultStatus(true);
        result{end+1}=ft1;
    end


end

function[FailingObjs,conditionStatus]=checkAlgo(system)
    FailingObjs=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    prodIntDivRoundTo=get_param(bdroot(system),'ProdIntDivRoundTo');
    if(strcmp(prodIntDivRoundTo,'Undefined'))


        blocks=find_system(system,'FollowLinks',inputParams{1}.Value,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks',inputParams{2}.Value,'RndMeth','Simplest');
        blocks=mdladvObj.filterResultWithExclusion(blocks);
        if~isempty(blocks)
            FailingObjs=blocks;
            conditionStatus=0;
        else
            conditionStatus=1;
        end
    else
        conditionStatus=2;
    end
end
