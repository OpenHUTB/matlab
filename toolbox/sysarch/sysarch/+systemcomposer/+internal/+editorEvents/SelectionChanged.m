
function SelectionChanged(h)




    systemcomposer.arch.BasePort.current(-1);

    if isempty(h)||~ishandle(h)
        return;
    end



    [~,bdH]=systemcomposer.InterfaceEditor.getActiveBD();


    if strcmp(get_param(bdroot(h),'isHarness'),'on')
        zcBlk=systemcomposer.internal.harness.getZCPeerForHarnessBlock(h);
        if~isempty(zcBlk)
            h=zcBlk;
        end
    end


    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
    if isempty(app)

        return;
    end


    systemcomposer.InterfaceEditor.ClearSelection(app.getName());


    dd=get_param(app.getName,'DataDictionary');

    if isempty(dd)

        viewModel=app.getInterfaceEditorViewModel();
        dictTreeTable=systemcomposer.InterfaceEditor.getDictionaryTreeTable(viewModel);
        treeTableRows=dictTreeTable.p_Rows.toArray;
    else

        try
            ddConn=Simulink.data.dictionary.open(dd);
            ieApp=systemcomposer.internal.InterfaceEditorApp.getInterfaceEditorAppForDictionary(ddConn.filepath());
            viewModel=ieApp.getViewModel;
            dictTreeTable=systemcomposer.InterfaceEditor.getDictionaryTreeTable(viewModel);
            treeTableRows=dictTreeTable.p_Rows.toArray;
        catch

            return
        end
    end


    archPort=systemcomposer.utils.getArchitecturePeer(h);
    if~isempty(archPort)&&isa(archPort,'systemcomposer.architecture.model.design.Port')



        systemcomposer.arch.BasePort.current(h);

        systemcomposer.InterfaceEditor.HiliteInterfaceForPort(app.getName(),archPort);

        app.resetPortInterfaceEditor(archPort);
    else
        systemcomposer.InterfaceEditor.resetIEToDictionaryScope(bdH);
        app.resetPortInterfaceEditor(systemcomposer.architecture.model.design.ArchitecturePort.empty);
        systemcomposer.InterfaceEditor.HiliteInterfaceForPort(app.getName(),'clear');
    end
end
