function outData=simrfV2_ce_divider(inData)























    outData=inData;
    blk=gcb;
    mdl=bdroot(blk);

    persistent mdlLastWarned
    dbstacknames={dbstack().name};
    if any(ismember(dbstacknames,{'upgradeadvisor','i_CheckModelHierarchy',...
        'Upgrader.doUpgradeOrAnalysis','checkDisconnectedDividerBlocks',...
        'actionDisconnectedDividerBlocks'}))
        mdlLastWarned=[];
        return
    elseif isequal(mdl,mdlLastWarned)
        return
    end




    params={inData.Name};
    vals={inData.Value};
    if strcmp(vals(strcmp(params,'DeviceDivider')),'Wilkinson power divider')
        mdlver=num2str(get_param(mdl,'VersionLoaded'));
        mdlrel=simulink_version(mdlver).release;
        commandToLaunchUpgAdv=sprintf('upgradeadvisor %s',mdl);
        hyperlink=sprintf('<a href="matlab:%s">%s</a>',...
        commandToLaunchUpgAdv,string(message(...
        'simrf:advisor:DisconnectedDividerBlocks_UpgradeAlertLinkText')));

        warnID='simrf:advisor:DisconnectedDividerBlocks_UpgradeAlert';


        backtraceStatus=warning('off','backtrace');
        backtraceRestore=onCleanup(@()warning(backtraceStatus));
        warning(warnID,string(message(warnID,mdl,mdlver,mdlrel,hyperlink)));

        mdlLastWarned=mdl;
    end
end