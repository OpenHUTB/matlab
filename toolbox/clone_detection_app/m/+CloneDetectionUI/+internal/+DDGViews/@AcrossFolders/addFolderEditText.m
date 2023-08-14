function addFolderEditText(obj)




    dlgH=obj.fDialogHandle;
    folderName=dlgH.getWidgetValue('FolderEditText');

    obj.selectedFolders{end+1,1}=folderName;
    dirtyEditor(obj);
end
