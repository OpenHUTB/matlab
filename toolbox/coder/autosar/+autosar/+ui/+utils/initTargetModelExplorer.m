




function explorer=initTargetModelExplorer(explorer,arRoot,compName,model,explorerTitle)

    m3iTerminalNode=autosar.ui.utils.viewAUTOSAR(arRoot,...
    'ShowComponentWithName',compName);
    if isempty(explorer)
        explorer=AUTOSAR.Explorer(m3iTerminalNode);
    end
    explorer.TraversedRoot=m3iTerminalNode;

    explorer.EditToolbar=autosar.ui.utils.getEditToolbar(explorer);
    autosar.ui.utils.registerListenerCB(arRoot);




    if~Simulink.internal.isArchitectureModel(model,'AUTOSARArchitecture')
        [isRefSharedDict,dictFiles]=...
        autosar.api.Utils.isUsingSharedAutosarDictionary(model);
        if isRefSharedDict
            assert(numel(dictFiles)==1,'Expected model to be linked to a single shared AUTOSAR dictionary.');
            dictFile=dictFiles{1};
            explorer.SharedAutosarDictionary=dictFile;
        end
    end


    explorer.alwaysShowUnappliedChangesDlg=true;

    am=DAStudio.ActionManager;
    am.initializeClient(explorer);
    explorer.icon=autosar.ui.configuration.PackageString.IconMap('title');
    explorer.setTreeTitle('');
    explorer.title=explorerTitle;
    explorer.MappingManager=get_param(model,'MappingManager');
    explorer.showListView(false);
    explorer.showDialogView(true);
    explorer.setDlgListViewLayoutVert(true);
    explorer.showContentsOf(true);
    explorer.showStatusBar(false);
    explorer.enableFreezePane(false);
    explorer.showContentsOfHyperlink(false);

    explorer.SelChangedCB=handle.listener(explorer,'METreeSelectionChanged',...
    {@autosar.ui.utils.selChangedCallback});
    explorer.ListSelChangedCB=handle.listener(explorer,'MEListSelectionChanged',...
    {@autosar.ui.utils.listSelChangedCallback});



    if~isempty(model)&&Simulink.internal.isArchitectureModel(model,'AUTOSARArchitecture')
        explorer.selectTreeItems('name',autosar.ui.metamodel.PackageString.Preferences);
        explorer.showTreeView(false);
    end

end



