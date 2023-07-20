
function result=actionSigLogSaveFormat(taskobj)




    mdladvObj=taskobj.MAObj;


    mdl=getfullname(mdladvObj.System);

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
        set_param(cs,'SignalLoggingSaveFormat','Dataset')
    end
    result=DAStudio.message('ModelAdvisor:engine:MASigLogSaveFormatCheckActionResults');


    hViewers=find_system(mdl,'AllBlocks','on','LookUnderMasks','on','IncludeCommented','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','Scope','IOType','viewer','SaveToWorkspace','on');
    if~isempty(hViewers)
        for indx=1:numel(hViewers)
            Simulink.scopes.logUnlogConnectedSignals(hViewers{indx},true);
        end
        result=DAStudio.message('ModelAdvisor:engine:MASigLogSaveFormatCheckActionResultsWithLoggingViewer');
    end
