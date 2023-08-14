function jmaab_jc_0611




    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0611');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0611_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0611';
    rec.setCallbackFcn(@checkCallBack,'PostCompile','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0611_tip');
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

function result=checkCallBack(system)
    FailingObjs=checkAlgo(system);
    result={};
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setInformation(DAStudio.message('ModelAdvisor:jmaab:jc_0611_tip'));
    ft.setSubBar(0);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    if~isempty(FailingObjs)
        ft.setListObj(FailingObjs');
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0611_issue'))
        ft.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0611_recAction'));
        mdladvObj.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0611_pass'));
        mdladvObj.setCheckResultStatus(true);
    end

    result{end+1}=ft;
end
function FailingObjs=checkAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;


    blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Product');
    blocks=mdladvObj.filterResultWithExclusion(blocks);
    flags=true(1,length(blocks));
    for bCount=1:length(blocks)
        blockHandle=blocks{bCount};
        if strcmp(get_param(blockHandle,'CompiledIsActive'),'on')
            compiledDataTypes=get_param(blockHandle,'CompiledPortDataTypes');
            if isempty(compiledDataTypes)
                continue;
            end
            inports=compiledDataTypes.Inport;
            usFlags=false(1,length(inports));
            fixFlags=false(1,length(inports));
            for ipCount=1:length(inports)

                dataType=Advisor.Utils.Simulink...
                .outDataTypeStr2baseType(system,inports{ipCount});




                if startsWith(dataType{1},'ufix')||startsWith(dataType{1},'sfix')
                    fixFlags(ipCount)=true;
                end
                if strcmp(dataType{1}(1),'u')
                    usFlags(ipCount)=true;
                end
            end



            if any(fixFlags)&&numel(unique(usFlags))~=1
                flags(bCount)=false;
            end
        end

    end
    FailingObjs=blocks(~flags);
end
