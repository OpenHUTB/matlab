function dlgStruct=getDialogSchema(this)

    libraryFileName.Name=DAStudio.message('sl_pir_cpp:creator:libraryFileName');
    libraryFileName.Type='edit';
    libraryFileName.RowSpan=[1,1];
    libraryFileName.ColSpan=[1,1];
    libraryFileName.Tag='libraryFileName';
    libraryFileName.Value=this.libFilenamesText;
    libraryFileName.WidgetId='libraryFileNameWidget';
    libraryFileName.ObjectMethod='saveLibFileNamesText';

    fileOrFolderCombo.Name=DAStudio.message('sl_pir_cpp:creator:fileOrFolderCombo');
    fileOrFolderCombo.Type='combobox';
    fileOrFolderCombo.Tag='fileOrFolderComboTag';
    fileOrFolderCombo.RowSpan=[1,1];
    fileOrFolderCombo.ColSpan=[2,2];
    fileOrFolderCombo.Entries={'Files','Folder'};
    fileOrFolderCombo.WidgetId='fileOrFolderComboWidget';

    uploadLibraryFile.Name=DAStudio.message('sl_pir_cpp:creator:browseBtnName');
    uploadLibraryFile.Type='pushbutton';
    uploadLibraryFile.RowSpan=[1,1];
    uploadLibraryFile.ColSpan=[3,3];
    uploadLibraryFile.ObjectMethod='browseLibraryFile';
    uploadLibraryFile.Tag='uploadLibrary';
    uploadLibraryFile.WidgetId='uploadLibraryFileWidgetId';

    groupLibraryFileName.Type='group';
    groupLibraryFileName.Name='';
    groupLibraryFileName.LayoutGrid=[1,3];
    groupLibraryFileName.Flat=true;
    groupLibraryFileName.Items={libraryFileName,fileOrFolderCombo,uploadLibraryFile};


    librariesTable.Type='table';
    librariesTable.ColHeader={DAStudio.message('sl_pir_cpp:creator:libraryFullPath')};
    librariesTable.Size=[size(this.cloneUIObj.libraryList,1),1];
    librariesTable.Data=this.cloneUIObj.libraryList;
    librariesTable.SelectionBehavior='Row';
    librariesTable.HeaderVisibility=[0,1];
    librariesTable.ColumnStretchable=[1];
    librariesTable.Editable=false;
    librariesTable.RowSpan=[2,2];
    librariesTable.ColSpan=[1,3];
    librariesTable.ValueChangedCallback=@tableChanged;
    librariesTable.DialogRefresh=true;
    librariesTable.Tag='AddLibrariesTable';
    librariesTable.WidgetId='AddLibrariesTableTableWidget';

    removeButton.Name=DAStudio.message('sl_pir_cpp:creator:removeLibrary');
    removeButton.Type='pushbutton';
    removeButton.RowSpan=[3,3];
    removeButton.ColSpan=[1,1];
    if isempty(this.cloneUIObj.libraryList)
        removeButton.Enabled=false;
    end
    removeButton.ObjectMethod='removeLibraryCallback';
    removeButton.DialogRefresh=true;
    removeButton.Tag='libraryRemoveItem';
    removeButton.WidgetId='libraryRemoveItemWidget';

    groupLibrary.Type='group';
    groupLibrary.Name='';
    groupLibrary.LayoutGrid=[3,3];
    groupLibrary.Flat=true;
    groupLibrary.Items={librariesTable,removeButton};

    dlgStruct.DialogTitle=this.title;
    dlgStruct.DialogTag='AddLibrary';
    dlgStruct.Items={groupLibraryFileName,groupLibrary};
    dlgStruct.PostApplyMethod='postApply';
    dlgStruct.DisplayIcon=fullfile(matlabroot,'toolbox','clone_detection_app','m',...
    'ui','images','detect_16.png');
    dlgStruct.LayoutGrid=[4,3];
end
