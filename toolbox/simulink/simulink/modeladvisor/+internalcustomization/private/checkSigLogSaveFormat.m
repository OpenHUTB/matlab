
function result=checkSigLogSaveFormat(system)





    result={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);



    if get_param(bdroot(system),'handle')~=get_param(system,'handle')
        result=DAStudio.message('Simulink:tools:MAUnableToRunCheckOnSubsystem');
        mdladvObj.setCheckResultStatus(false);
        return;
    end


    closeMdlObj=Simulink.SimulationData.ModelCloseUtil(true);%#ok<NASGU>

    topMdl=bdroot(system);
    hasMdlLog=isConfiguredForModelDataLogs(topMdl);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(false);
    ft.setInformation(DAStudio.message('ModelAdvisor:engine:MATitletipCheckSigLogSaveFormatDocInfo'));
    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};

    haveViewersLoggingInMdlLog=areViewersLoggingInModelDataLogs(topMdl);
    if hasMdlLog
        currentCheckObj.Action.Enable=true;
        ft.setSubResultStatus('warn');
        mdladvObj.setCheckResultStatus(false);
        if~haveViewersLoggingInMdlLog
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MASigLogSaveFormatCheckWarn'));
            ft.setRecAction(DAStudio.message('ModelAdvisor:engine:MARecommendationCheckSigLogSaveFormat'));
        else
            ft.setInformation(DAStudio.message('ModelAdvisor:engine:MATitletipCheckSigLogSaveFormatDocInfoWithLoggingViewer'));
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MASigLogSaveFormatCheckWarnWithLoggingViewer'));
            ft.setRecAction(DAStudio.message('ModelAdvisor:engine:MARecommendationCheckSigLogSaveFormatWithLoggingViewer'));
        end
    else
        currentCheckObj.Action.Enable=false;
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        if Simulink.internal.useFindSystemVariantsMatchFilter()
            [~,mdlBlks]=find_mdlrefs(bdroot(system),...
            'AllLevels',false,...
            'IncludeProtectedModels',false,...
            'MatchFilter',@Simulink.match.activeVariants);
        else

            [~,mdlBlks]=find_mdlrefs(bdroot(system),...
            'AllLevels',false,...
            'IncludeProtectedModels',false,...
            'Variants','ActiveVariants');
        end
        if~isempty(mdlBlks)
            docLinkConvert='<a href="matlab:doc Simulink.SimulationData.updateDatasetFormatLogging">Simulink.SimulationData.updateDatasetFormatLogging</a>';
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MASigLogSaveFormatCheckPassMdlRef',docLinkConvert));
        else
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MASigLogSaveFormatCheckPass'));
        end
    end

    result{end+1}=ft;



    function hasMdlLog=isConfiguredForModelDataLogs(mdl)
        csNames=getConfigSets(mdl);
        for idx=1:length(csNames)
            csName=csNames{idx};
            cs=getConfigSet(mdl,csName);
            if isa(cs,'Simulink.ConfigSetRef')
                try
                    cs=cs.getRefConfigSet;
                catch %#ok<CTCH>

                    continue;
                end
            end
            sigFmt=get_param(cs,'SignalLoggingSaveFormat');
            if(strcmp(sigFmt,'ModelDataLogs'))
                hasMdlLog=true;
                return;
            end
        end
        hasMdlLog=false;
        return;


        function b=areViewersLoggingInModelDataLogs(mdl)


            hViewers=find_system(mdl,'AllBlocks','on','LookUnderMasks','on','IncludeCommented','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','Scope','IOType','viewer','SaveToWorkspace','on');
            b=~isempty(hViewers);

