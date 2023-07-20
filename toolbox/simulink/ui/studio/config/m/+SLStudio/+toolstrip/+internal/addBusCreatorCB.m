



function addBusCreatorCB(cbinfo,~)

    editor=cbinfo.studio.App.getActiveEditor;
    refactorInterface=Simulink.internal.CompositePorts.RefactorInterfaceWrapper(editor,editor.getSelection);
    if refactorInterface.canExecute()
        editor.createMCommandWithAdditionalModels('Simulink:BusElPorts:RefactorInterface',DAStudio.message('Simulink:BusElPorts:RefactorInterface'),@refactorInterface.execute,{},instance.getAdditionalModels());
    else
        createBus=Simulink.internal.CompositePorts.CreateBusWrapper(editor,editor.getSelection);
        editor.createMCommand('Simulink:studio:MACreateBus',DAStudio.message('Simulink:studio:MACreateBus'),@createBus.execute,{});
    end
end
