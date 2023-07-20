function mdlAdvisorRmi(obj)




    modelH=rmisl.getmodelh(obj);

    filterSettings=rmi.settings_mgr('get','filterSettings');
    if filterSettings.enabled&&filterSettings.filterConsistency
        reply=questdlg(...
        getString(message('Slvnv:reqmgt:rmi:UserFilterActive')),...
        getString(message('Slvnv:reqmgt:rmi:RequirementsConsistencyChecking')),...
        'Continue','Turn filters off','Cancel','Continue');
        if isempty(reply)
            reply='Continue';
        end
        if strcmp(reply,'Turn filters off')
            filterSettings.filterConsistency=false;
            rmi.settings_mgr('set','filterSettings',filterSettings);
        elseif strcmp(reply,'Cancel')
            return;
        end
    end

    ma=Simulink.ModelAdvisor.getModelAdvisor(modelH,'new');
    ma.TaskAdvisorRoot.changeSelectionStatus(false);
    p=ma.getTaskObj('_SYSTEM_By Task_Requirement consistency checking');
    if~isempty(p)
        p.changeSelectionStatus(true);
        if slfeature('AdvisorWebUI')
            ma.displayExplorer();
            wCtrl=ma.AdvisorWindow.Controller;
            wCtrl.selectNode(p.ID);
        else

            modeladvisor(modelH);
            me=ma.MAExplorer;
            imme=DAStudio.imExplorer(me);
            imme.collapseTreeNode(ma.TaskAdvisorCellArray{1});
            imme.selectTreeViewNode(p);
            imme.expandTreeNode(p);
        end
    end
end
