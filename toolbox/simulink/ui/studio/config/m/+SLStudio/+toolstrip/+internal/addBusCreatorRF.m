



function addBusCreatorRF(cbinfo,action)

    editor=cbinfo.studio.App.getActiveEditor;
    sel=editor.getSelection;
    if~sel.isEmpty
        refactorInterface=Simulink.internal.CompositePorts.RefactorInterfaceWrapper(editor,sel);
        createBus=Simulink.internal.CompositePorts.CreateBusWrapper(editor,sel);
        action.enabled=refactorInterface.canExecute()||createBus.canExecute();
    else
        action.enabled=false;
    end
end
