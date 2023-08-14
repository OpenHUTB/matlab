function createNewSDInputDialog(rootUri)


    [mdlHandle,~]=builtin('_get_sl_object_instance_handle_from_sequence_diagram_uri','',rootUri);
    mdlName=get_param(mdlHandle,'Name');

    dp=DAStudio.DialogProvider;
    inputdlg=dp.inputdlg('Enter sequence diagram name:','New Sequence Diagram','',...
    @(newSDName)(sequencediagram.web.createSequenceDiagramAndOpen(mdlName,newSDName)));


    imd=DAStudio.imDialog.getIMWidgets(inputdlg);
    inputBox=imd.find('-isa','DAStudio.imEdit');
    inputBox.setFocus();

end


