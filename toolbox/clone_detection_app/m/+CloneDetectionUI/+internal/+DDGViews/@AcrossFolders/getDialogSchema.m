function dlgStruct=getDialogSchema(this)





    folderEdit.Name=DAStudio.message('sl_pir_cpp:creator:AcrossFoldersEditTitle');
    folderEdit.Type='edit';
    folderEdit.RowSpan=[1,1];
    folderEdit.ColSpan=[1,1];
    folderEdit.Tag='FolderEditText';
    folderEdit.Value='';
    folderEdit.ObjectMethod='addFolderEditText';









    uploadLibraryFile.Name=DAStudio.message('sl_pir_cpp:creator:browseBtnName');
    uploadLibraryFile.Type='pushbutton';
    uploadLibraryFile.RowSpan=[1,1];
    uploadLibraryFile.ColSpan=[3,3];
    uploadLibraryFile.ObjectMethod='browseFolders';
    uploadLibraryFile.Tag='browseFolders';
    uploadLibraryFile.WidgetId='browseFoldersWidgetId';

    groupFolderSelector.Type='group';
    groupFolderSelector.Name='';
    groupFolderSelector.LayoutGrid=[1,4];
    groupFolderSelector.Flat=true;
    groupFolderSelector.Items={folderEdit,uploadLibraryFile};


    DepedendenciesButton.Name=DAStudio.message('sl_pir_cpp:creator:AcrossFolderAddDependencies');
    DepedendenciesButton.Type='pushbutton';
    DepedendenciesButton.RowSpan=[1,1];
    DepedendenciesButton.ColSpan=[1,1];
    DepedendenciesButton.ObjectMethod='browseLibraryFile';
    DepedendenciesButton.Tag='uploadLibrary';
    DepedendenciesButton.WidgetId='uploadLibraryFileWidgetId';

    varEdit.Name=DAStudio.message('sl_pir_cpp:creator:AcrossFolderWorkspaceVariableName');
    varEdit.Type='edit';
    varEdit.RowSpan=[1,1];
    varEdit.ColSpan=[2,2];
    varEdit.Tag='varEdit';
    varEdit.Value='';

    importButton.Name=DAStudio.message('sl_pir_cpp:creator:AcrossFolderImportFromWorkspace');
    importButton.Type='pushbutton';
    importButton.RowSpan=[1,1];
    importButton.ColSpan=[3,3];
    importButton.ObjectMethod='importFromBaseWorkspace';
    importButton.Tag='importFromWorkSpace';
    importButton.WidgetId='importFromWorkSpaceWidgetId';

    exportButton.Name=DAStudio.message('sl_pir_cpp:creator:AcrossFolderExportToWorkspace');
    exportButton.Type='pushbutton';
    exportButton.RowSpan=[1,1];
    exportButton.ColSpan=[4,4];
    exportButton.ObjectMethod='exportToBaseWorkspace';
    exportButton.Tag='exportToWorkSpace';
    exportButton.WidgetId='exportToWorkWidgetId';


    convenienceGroup.Type='group';
    convenienceGroup.Name='';
    groupFolderSelector.Flat=true;
    convenienceGroup.LayoutGrid=[1,1];
    convenienceGroup.Items={varEdit,importButton,exportButton};




    FoldersTable.Type='table';
    FoldersTable.ColHeader={DAStudio.message('sl_pir_cpp:creator:AcrossFolderTableName')};
    FoldersTable.Size=[length(this.selectedFolders),1];
    FoldersTable.Data=this.selectedFolders;
    FoldersTable.SelectionBehavior='Row';
    FoldersTable.HeaderVisibility=[0,1];
    FoldersTable.ColumnStretchable=[1];
    FoldersTable.Editable=false;
    FoldersTable.RowSpan=[2,2];
    FoldersTable.ColSpan=[1,3];
    FoldersTable.ValueChangedCallback=@tableChanged;
    FoldersTable.DialogRefresh=true;
    FoldersTable.Tag='AddFoldersTable';
    FoldersTable.WidgetId='AddFoldersTablWidget';


    groupLibrary.Type='group';
    groupLibrary.Name='';
    groupLibrary.LayoutGrid=[3,3];
    groupLibrary.Flat=true;
    groupLibrary.Items={FoldersTable};

    dlgStruct.DialogTitle='Find Clones In Folders';
    dlgStruct.DialogTag='FindAcrossFolders';
    dlgStruct.Items={groupFolderSelector,convenienceGroup,groupLibrary};
    dlgStruct.PostApplyMethod='postApply';
    dlgStruct.DisplayIcon=fullfile(matlabroot,'toolbox','clone_detection_app','m',...
    'ui','images','detect_16.png');
    dlgStruct.LayoutGrid=[5,3];
end
