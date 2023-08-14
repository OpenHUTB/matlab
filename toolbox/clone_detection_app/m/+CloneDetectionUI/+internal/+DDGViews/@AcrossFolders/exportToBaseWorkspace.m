function exportToBaseWorkspace(obj)




    dlgH=obj.fDialogHandle;
    varName=dlgH.getWidgetValue('varEdit');

    if isvarname(varName)
        assignin('base',varName,obj.selectedFolders);
    else
        errordlg('sl_pir_cpp:creator:IllegalExportVariable');
    end
end
