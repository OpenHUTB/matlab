function importFromBaseWorkspace(obj)




    dlgH=obj.fDialogHandle;
    varName=dlgH.getWidgetValue('varEdit');

    if isempty(varName)||~iscellstr(varName)
        errordlg('sl_pir_cpp:creator:IllegalImportVariable');
    end

    varVal=evalin('base',varName);

    if iscellstr(varVal)&&size(varVal,2)==1
        obj.selectedFolders=varVal;
        dirtyEditor(obj);
    end
end
