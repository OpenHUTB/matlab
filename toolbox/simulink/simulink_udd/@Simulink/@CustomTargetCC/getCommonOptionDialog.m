function dlg=getCommonOptionDialog(hObj,schemaName)




    dlgController=getDialogController(hObj);
    dlg=getTargetSoftwareDialogGroup(dlgController,schemaName);

