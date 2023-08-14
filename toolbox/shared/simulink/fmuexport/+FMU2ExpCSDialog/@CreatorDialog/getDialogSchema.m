function schema=getDialogSchema(obj)





    tag_prefix='fmu2expcs_';


    opt=obj.getOptions;



    lblDescription.Type='text';
    lblDescription.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSDescriptionContent');
    lblDescription.RowSpan=[1,1];
    lblDescription.ColSpan=[1,1];
    lblDescription.Tag=[tag_prefix,'Description'];
    lblDescription.WordWrap=true;

    grpFMU2ExpCSDescription.Type='group';
    grpFMU2ExpCSDescription.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSDescriptionLabel');
    grpFMU2ExpCSDescription.LayoutGrid=[1,1];
    items={lblDescription};

    grpFMU2ExpCSDescription.Items=items;


    items={};
    rowCounter=1;
    rowStretchVect=0;

    if license('test','Real-Time_Workshop')

        saveCodeSupport.Type='checkbox';
        saveCodeSupport.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSSaveSourceCodeToFMU');
        saveCodeSupport.RowSpan=[rowCounter,rowCounter];
        saveCodeSupport.ColSpan=[1,1];
        saveCodeSupport.Mode=1;
        saveCodeSupport.Graphical=1;
        saveCodeSupport.Source=obj;
        saveCodeSupport.ObjectMethod='OM_SaveSourceCodeToFMU';
        saveCodeSupport.MethodArgs={'%dialog'};
        saveCodeSupport.ArgDataTypes={'handle'};
        saveCodeSupport.Tag=[tag_prefix,'SaveSourceCodeToFMU'];
        saveCodeSupport.Value=opt.SaveSourceCodeToFMU;


        items=[items,{saveCodeSupport}];

        gen32BitBinaryColSpan=[2,2];
    else
        gen32BitBinaryColSpan=[1,1];
    end


    gen32BitBinary.Type='checkbox';
    gen32BitBinary.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSGenerate32BitDLLLabel');
    gen32BitBinary.RowSpan=[rowCounter,rowCounter];
    gen32BitBinary.ColSpan=gen32BitBinaryColSpan;
    gen32BitBinary.Mode=1;
    gen32BitBinary.Graphical=1;
    gen32BitBinary.Source=obj;
    gen32BitBinary.ObjectMethod='OM_Generate32BitDLL';
    gen32BitBinary.MethodArgs={'%dialog'};
    gen32BitBinary.ArgDataTypes={'handle'};
    gen32BitBinary.Tag=[tag_prefix,'Generate32BitDLL'];
    gen32BitBinary.Value=opt.Generate32BitDLL;

    gen32BitBinary.Visible=ispc;


    items=[items,{gen32BitBinary}];


    rowCounter=rowCounter+1;
    rowStretchVect=[rowStretchVect,0];
    dropdownAddIcon.Type='combobox';
    dropdownAddIcon.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconLabel');
    dropdownAddIcon.Entries=[...
    {DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconDropdownSnapshot')};...
    {DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconDropdownFile')};...
    {DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconDropdownOff')}];
    dropdownAddIcon.RowSpan=[rowCounter,rowCounter];
    dropdownAddIcon.ColSpan=[1,1];
    dropdownAddIcon.Mode=1;
    dropdownAddIcon.Graphical=1;
    dropdownAddIcon.Source=obj;
    dropdownAddIcon.ObjectMethod='OM_AddIcon';
    dropdownAddIcon.MethodArgs={'%dialog'};
    dropdownAddIcon.ArgDataTypes={'handle'};
    dropdownAddIcon.Tag=[tag_prefix,'AddIconDropdown'];
    dropdownAddIcon.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconDropdownTooltip');
    dropdownAddIcon.Value=opt.AddIcon;

    items=[items,{dropdownAddIcon}];


    addIconPath.Type='edit';
    addIconPath.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconFileLabel');
    addIconPath.RowSpan=[rowCounter,rowCounter];
    addIconPath.ColSpan=[2,2];
    addIconPath.ObjectProperty='titleImgPath';
    addIconPath.Enabled=(opt.AddIcon==1);
    addIconPath.Mode=1;
    addIconPath.Graphical=1;
    addIconPath.Tag=[tag_prefix,'AddIconPath'];
    addIconPath.Value=opt.AddIconPath;


    addIconBrowse.Type='pushbutton';
    addIconBrowse.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconButtonLabel');
    addIconBrowse.RowSpan=[rowCounter,rowCounter];
    addIconBrowse.ColSpan=[3,3];
    addIconBrowse.Enabled=(opt.AddIcon==1);
    addIconBrowse.Mode=1;
    addIconBrowse.Graphical=1;
    addIconBrowse.Source=obj;
    addIconBrowse.ObjectMethod='browseImage';
    addIconBrowse.MethodArgs={'%dialog'};
    addIconBrowse.ArgDataTypes={'handle'};
    addIconBrowse.Tag=[tag_prefix,'AddIconBrowse'];
    addIconBrowse.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconButtonTooltip');

    items=[items,{addIconPath,addIconBrowse}];


    if slfeature('FMUNativeSimulinkBehavior')>0
        rowCounter=rowCounter+1;
        rowStretchVect=[rowStretchVect,0];
        AddNativeSimulinkBehavior.Type='checkbox';
        AddNativeSimulinkBehavior.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSAddNativeSimulinkBehavior');
        AddNativeSimulinkBehavior.RowSpan=[rowCounter,rowCounter];
        AddNativeSimulinkBehavior.ColSpan=[1,1];
        AddNativeSimulinkBehavior.Mode=1;
        AddNativeSimulinkBehavior.Graphical=1;
        AddNativeSimulinkBehavior.Source=obj;
        AddNativeSimulinkBehavior.ObjectMethod='OM_AddNativeSimulinkBehavior';
        AddNativeSimulinkBehavior.MethodArgs={'%dialog'};
        AddNativeSimulinkBehavior.ArgDataTypes={'handle'};
        AddNativeSimulinkBehavior.Tag=[tag_prefix,'AddNativeSimulinkBehavior'];
        AddNativeSimulinkBehavior.Visible=1;
        AddNativeSimulinkBehavior.Value=opt.AddNativeSimulinkBehavior;

        items=[items,{AddNativeSimulinkBehavior}];
    end


    if slfeature('FMUExportParameterConfiguration')>0


        paramDesc.Type='text';
        paramDesc.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterText');
        paramDesc.RowSpan=[1,1];
        paramDesc.ColSpan=[1,8];
        paramDesc.Tag=[tag_prefix,'paramDesc'];

        filterEdit.Type='spreadsheetfilter';
        filterEdit.Tag=[tag_prefix,'filterEdit'];
        filterEdit.RowSpan=[2,2];
        filterEdit.ColSpan=[1,8];
        filterEdit.TargetSpreadsheet=[tag_prefix,'paramList'];
        filterEdit.PlaceholderText='Filter by name or description';
        filterEdit.Clearable=true;

        paramList.Type='spreadsheet';
        paramList.Columns={DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterName'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterExported'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterSource'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterDescription'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterUnit'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterExportedName')};
        paramList.RowSpan=[3,3];
        paramList.ColSpan=[1,8];
        paramList.Tag=[tag_prefix,'paramList'];
        paramList.DialogRefresh=false;
        paramList.Hierarchical=true;
        paramList.Source=obj.paramListSource;

        modelExplorer_link.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterOpenModelExplorer');
        modelExplorer_link.Type='hyperlink';
        modelExplorer_link.Enabled=1;
        modelExplorer_link.RowSpan=[4,4];
        modelExplorer_link.ColSpan=[1,2];
        modelExplorer_link.Tag=[tag_prefix,'model_explorer_link'];
        modelExplorer_link.MatlabMethod='slexplr';

        selectAllButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterSelectAll');
        selectAllButton.Type='pushbutton';
        selectAllButton.Enabled=1;
        selectAllButton.RowSpan=[4,4];
        selectAllButton.ColSpan=[6,6];
        selectAllButton.Tag=[tag_prefix,'selectAll'];
        selectAllButton.Source=obj;
        selectAllButton.ObjectMethod='selectAll';
        selectAllButton.MethodArgs={'%dialog','%tag'};
        selectAllButton.ArgDataTypes={'handle','string'};
        selectAllButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterSelectAllTooltip');

        unselectButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterUnselectAll');
        unselectButton.Type='pushbutton';
        unselectButton.Enabled=1;
        unselectButton.RowSpan=[4,4];
        unselectButton.ColSpan=[7,7];
        unselectButton.Tag=[tag_prefix,'unselectAll'];
        unselectButton.Source=obj;
        unselectButton.ObjectMethod='unselectAll';
        unselectButton.MethodArgs={'%dialog','%tag'};
        unselectButton.ArgDataTypes={'handle','string'};
        unselectButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterUnselectAllTooltip');

        resetButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterReset');
        resetButton.Type='pushbutton';
        resetButton.Enabled=1;
        resetButton.RowSpan=[4,4];
        resetButton.ColSpan=[8,8];
        resetButton.Tag=[tag_prefix,'reset_paramList'];
        resetButton.Source=obj;
        resetButton.ObjectMethod='reset_List';
        resetButton.MethodArgs={'%dialog','%tag'};
        resetButton.ArgDataTypes={'handle','string'};
        resetButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterResetTooltip');


        stretchRow=1;
        paramConfig.Type='togglepanel';
        paramConfig.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterDetails');
        paramConfig.RowSpan=[stretchRow,stretchRow];
        paramConfig.ColSpan=[1,3];
        paramConfig.LayoutGrid=[4,8];
        paramConfig.RowStretch=[0,0,1,0];
        paramConfig.ColStretch=[1,zeros(1,7)];
        paramConfig.Items={paramDesc,filterEdit,paramList,modelExplorer_link,selectAllButton,unselectButton,resetButton};
        paramConfig.Tag=[tag_prefix,'ParameterDetails'];
    end


    if slfeature('FMUExportInternalVarConfiguration')>0

        ivDesc.Type='text';
        ivDesc.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVText');
        ivDesc.RowSpan=[1,1];
        ivDesc.ColSpan=[1,8];
        ivDesc.Tag=[tag_prefix,'ivDesc'];

        filterEdit.Type='spreadsheetfilter';
        filterEdit.Tag=[tag_prefix,'iv_filterEdit'];
        filterEdit.RowSpan=[2,2];
        filterEdit.ColSpan=[1,8];
        filterEdit.TargetSpreadsheet=[tag_prefix,'ivList'];
        filterEdit.PlaceholderText='Filter by name or description';
        filterEdit.Clearable=true;

        ivList.Type='spreadsheet';
        ivList.Columns={DAStudio.message('FMUExport:FMU:FMU2ExpCSIVName'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSIVExported'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSIVSource'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSIVDescription'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSIVUnit'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSIVExportedName'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSIVDatatype'),...
        DAStudio.message('FMUExport:FMU:FMU2ExpCSIVExportedDatatype')};
        ivList.RowSpan=[3,3];
        ivList.ColSpan=[1,8];
        ivList.Tag=[tag_prefix,'ivList'];
        ivList.DialogRefresh=false;
        ivList.Hierarchical=true;
        ivList.Source=obj.ivListSource;

        modelDataEditor_link.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVOpenModelDataEditor');
        modelDataEditor_link.Type='hyperlink';
        modelDataEditor_link.Enabled=1;
        modelDataEditor_link.RowSpan=[4,4];
        modelDataEditor_link.ColSpan=[1,2];
        modelDataEditor_link.Tag=[tag_prefix,'model_data_editor_link'];
        modelDataEditor_link.ObjectMethod='openModelDataEditorCB';
        modelDataEditor_link.MethodArgs={'%dialog'};
        modelDataEditor_link.ArgDataTypes={'handle'};

        selectAllButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVSelectAll');
        selectAllButton.Type='pushbutton';
        selectAllButton.Enabled=1;
        selectAllButton.RowSpan=[4,4];
        selectAllButton.ColSpan=[6,6];
        selectAllButton.Tag=[tag_prefix,'iv_selectAll'];
        selectAllButton.Source=obj;
        selectAllButton.ObjectMethod='selectAll';
        selectAllButton.MethodArgs={'%dialog','%tag'};
        selectAllButton.ArgDataTypes={'handle','string'};
        selectAllButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVSelectAllTooltip');

        unselectButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVUnselectAll');
        unselectButton.Type='pushbutton';
        unselectButton.Enabled=1;
        unselectButton.RowSpan=[4,4];
        unselectButton.ColSpan=[7,7];
        unselectButton.Tag=[tag_prefix,'iv_unselectAll'];
        unselectButton.Source=obj;
        unselectButton.ObjectMethod='unselectAll';
        unselectButton.MethodArgs={'%dialog','%tag'};
        unselectButton.ArgDataTypes={'handle','string'};
        unselectButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVUnselectAllTooltip');

        resetButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVReset');
        resetButton.Type='pushbutton';
        resetButton.Enabled=1;
        resetButton.RowSpan=[4,4];
        resetButton.ColSpan=[8,8];
        resetButton.Tag=[tag_prefix,'reset_ivList'];
        resetButton.Source=obj;
        resetButton.ObjectMethod='reset_List';
        resetButton.MethodArgs={'%dialog','%tag'};
        resetButton.ArgDataTypes={'handle','string'};
        resetButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVResetTooltip');


        stretchRow=stretchRow+1;
        ivConfig.Type='togglepanel';
        ivConfig.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVDetails');
        ivConfig.RowSpan=[stretchRow,stretchRow];
        ivConfig.ColSpan=[1,3];
        ivConfig.LayoutGrid=[4,8];
        ivConfig.RowStretch=[0,0,1,0];
        ivConfig.ColStretch=[1,zeros(1,7)];
        ivConfig.Items={ivDesc,filterEdit,ivList,modelDataEditor_link,selectAllButton,unselectButton,resetButton};
        ivConfig.Tag=[tag_prefix,'InternalVariableDetails'];
    end





    packageDesc.Type='text';
    packageDesc.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageText');
    packageDesc.RowSpan=[1,1];
    packageDesc.ColSpan=[1,8];
    packageDesc.Tag=[tag_prefix,'packageDesc'];


    filterEdit.Type='spreadsheetfilter';
    filterEdit.Tag=[tag_prefix,'resourcesFilterEdit'];
    filterEdit.RowSpan=[3,3];
    filterEdit.ColSpan=[1,8];
    filterEdit.TargetSpreadsheet=[tag_prefix,'packageList'];
    filterEdit.PlaceholderText=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageFilterSearchText');
    filterEdit.Clearable=true;


    packageList.Type='spreadsheet';
    packageList.Columns={' ',DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageEntityName'),...
    DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageSourceFolder'),...
    DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageDestinationFolder')};
    packageList.RowSpan=[3,3];
    packageList.ColSpan=[1,8];
    packageList.Tag=[tag_prefix,'packageList'];
    packageList.DialogRefresh=true;
    packageList.Hierarchical=false;
    packageList.Source=obj.packageList;


    packageColumnJSON=...
    strcat('{"columns" : [{"name" : "",  "width" : 40},',...
    ['{"name" : "',getString(message('FMUExport:FMU:FMU2ExpCSPackageEntityName')),'",  "width" : -1},'],...
    ['{"name" : "',getString(message('FMUExport:FMU:FMU2ExpCSPackageSourceFolder')),'",  "width" : -1},'],...
    ['{"name" : "',getString(message('FMUExport:FMU:FMU2ExpCSPackageDestinationFolder')),'",  "width" : -1}] }']);
    packageList.Config=packageColumnJSON;
    packageList.ValueChangedCallback=@(tag,sels,name,value,dlg)obj.packageList_spreadSheetValue(tag,sels,name,value,dlg);


    addButton.Name='';
    addButton.Type='splitbutton';
    addButton.Enabled=1;
    addButton.RowSpan=[4,4];
    addButton.ColSpan=[6,6];
    addButton.Tag=[tag_prefix,'add_packageList'];
    addButton.ActionEntries={...
    FMU2ExpCSDialog.PackageFolderAction(obj),...
    FMU2ExpCSDialog.PackageFileAction(obj),...
    };
    addButton.DefaultAction='fileButtonAction';
    addButton.UseButtonStyleForDefaultAction=false;
    addButton.ActionCallback=@(dlg,w,action)obj.add_packageList(dlg,w,action);
    addButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageAddTooltip');


    selectAllButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterSelectAll');
    selectAllButton.Type='pushbutton';
    selectAllButton.Enabled=1;
    selectAllButton.RowSpan=[4,4];
    selectAllButton.ColSpan=[7,7];
    selectAllButton.Tag=[tag_prefix,'packageSelectAll'];
    selectAllButton.Source=obj;
    selectAllButton.ObjectMethod='package_selectAll';
    selectAllButton.MethodArgs={'%dialog'};
    selectAllButton.ArgDataTypes={'handle'};
    selectAllButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageSelectAllTooltip');


    removeButton.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageRemove');
    removeButton.Type='pushbutton';
    removeButton.Enabled=1;
    removeButton.RowSpan=[4,4];
    removeButton.ColSpan=[8,8];
    removeButton.Tag=[tag_prefix,'remove_packageList'];
    removeButton.Source=obj;
    removeButton.ObjectMethod='remove_packageList';
    removeButton.MethodArgs={'%dialog'};
    removeButton.ArgDataTypes={'handle'};
    removeButton.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageRemoveTooltip');


    stretchRow=stretchRow+1;
    packageConfig.Type='togglepanel';
    packageConfig.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageDetails');
    packageConfig.RowSpan=[stretchRow,stretchRow];
    packageConfig.ColSpan=[1,3];
    packageConfig.LayoutGrid=[4,8];
    packageConfig.RowStretch=[0,0,1,0];
    packageConfig.ColStretch=[1,zeros(1,7)];
    packageConfig.Items={packageDesc,filterEdit,packageList,...
    selectAllButton,removeButton,addButton};
    packageConfig.Tag=[tag_prefix,'PackageDetails'];


    rowCounter=rowCounter+1;
    rowStretchVect=[rowStretchVect,1];
    stretchGrp.Type='panel';
    stretchGrp.Tag='stract';
    stretchGrp.Visible=true;
    stretchGrp.ColSpan=[1,3];
    stretchGrp.RowSpan=[rowCounter,rowCounter];
    stretchGrp.LayoutGrid=[stretchRow,3];
    stretchGrp.RowStretch=[1,zeros(1,stretchRow-1)];
    if slfeature('FMUExportInternalVarConfiguration')>0
        stretchGrp.Items={paramConfig,ivConfig,packageConfig};
    else
        stretchGrp.Items={paramConfig,packageConfig};
    end
    items=[items,{stretchGrp}];


    grpContents.Type='group';
    grpContents.Visible=true;
    grpContents.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSCapabilitiesLabel');
    grpContents.Tag=[tag_prefix,'PackageCapabilites'];
    grpContents.LayoutGrid=[rowCounter,3];
    grpContents.ColStretch=[0,1,0];
    grpContents.RowStretch=rowStretchVect;

    grpContents.Items=items;


    items={};
    rowCounter=1;


    editPackagePath.Type='edit';
    editPackagePath.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSPathEditLabel');
    editPackagePath.RowSpan=[rowCounter,rowCounter];
    editPackagePath.ColSpan=[1,1];
    editPackagePath.Mode=1;
    editPackagePath.Graphical=1;
    editPackagePath.Tag=[tag_prefix,'PackagePath'];
    editPackagePath.Value=opt.PackagePath;


    packagePathBrowse.Type='pushbutton';
    packagePathBrowse.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSBrowseButtonLabel');
    packagePathBrowse.RowSpan=[rowCounter,rowCounter];
    packagePathBrowse.ColSpan=[2,2];
    packagePathBrowse.Mode=1;
    packagePathBrowse.Graphical=1;
    packagePathBrowse.Source=obj;
    packagePathBrowse.ObjectMethod='browsePackagePath';
    packagePathBrowse.MethodArgs={'%dialog'};
    packagePathBrowse.ArgDataTypes={'handle'};
    packagePathBrowse.Tag=[tag_prefix,'BrowseOutputDirButton'];
    packagePathBrowse.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSBrowseButtonTooltip');

    items=[items,{editPackagePath,packagePathBrowse}];
    rowCounter=rowCounter+1;


    viewSupport.Type='combobox';
    viewSupport.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSExportedContentLabel');
    viewSupport.Entries=[...
    {DAStudio.message('FMUExport:FMU:FMU2ExpCSExportedContentDropdownProjectWithHarnessModel')};...
    {DAStudio.message('FMUExport:FMU:FMU2ExpCSExportedContentDropdownOff')}];
    viewSupport.RowSpan=[rowCounter,rowCounter];
    viewSupport.ColSpan=[1,1];
    viewSupport.Visible=1;
    viewSupport.Mode=1;
    viewSupport.Graphical=1;
    viewSupport.Source=obj;
    viewSupport.ObjectMethod='OM_ExportedContent';
    viewSupport.MethodArgs={'%dialog'};
    viewSupport.ArgDataTypes={'handle'};
    viewSupport.Tag=[tag_prefix,'ExportedContent'];
    viewSupport.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSExportedContentDropdownTooltip');
    viewSupport.Value=opt.ExportedContent;

    items=[items,{viewSupport}];
    rowCounter=rowCounter+1;


    createModelCheckbox.Type='checkbox';
    createModelCheckbox.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSCreateModelAfterGeneratingFMULabel');
    createModelCheckbox.RowSpan=[rowCounter,rowCounter];
    createModelCheckbox.ColSpan=[1,1];
    createModelCheckbox.Mode=1;
    createModelCheckbox.Graphical=1;
    createModelCheckbox.Source=obj;
    createModelCheckbox.ObjectMethod='OM_CreateModelAfterGeneratingFMU';
    createModelCheckbox.MethodArgs={'%dialog'};
    createModelCheckbox.ArgDataTypes={'handle'};
    createModelCheckbox.Tag=[tag_prefix,'CreateModelAfterGeneratingFMU'];
    createModelCheckbox.Value=opt.CreateModelAfterGeneratingFMU;
    if opt.ExportedContent==0
        createModelCheckbox.Enabled=false;
    else
        createModelCheckbox.Enabled=true;
    end


    items=[items,{createModelCheckbox}];
    rowCounter=rowCounter+1;


    editProjectName.Type='edit';
    editProjectName.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSProjectEditLabel');
    editProjectName.RowSpan=[rowCounter,rowCounter];
    editProjectName.ColSpan=[1,1];
    editProjectName.Mode=1;
    editProjectName.Graphical=1;
    editProjectName.Tag=[tag_prefix,'ProjectName'];
    if opt.ExportedContent==1
        editProjectName.Value='';
        editProjectName.Enabled=false;
    else
        editProjectName.Value=opt.ProjectName;
        editProjectName.Enabled=true;
    end

    items=[items,{editProjectName}];
    rowCounter=rowCounter+1;


    grpContentsOptions.Type='group';
    grpContentsOptions.Visible=true;
    grpContentsOptions.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSOptionsLabel');
    grpContentsOptions.Tag=[tag_prefix,'PackageOptions'];
    grpContentsOptions.LayoutGrid=[rowCounter,2];
    grpContentsOptions.ColStretch=[1,0];
    grpContentsOptions.RowStretch=zeros(1,rowCounter);

    grpContentsOptions.Items=items;


    btnGenerate.Type='pushbutton';
    btnGenerate.RowSpan=[1,1];
    btnGenerate.ColSpan=[3,3];
    btnGenerate.Mode=1;
    btnGenerate.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSCreateButtonLabel');
    btnGenerate.ObjectMethod='generate';
    btnGenerate.Source=obj;
    btnGenerate.MethodArgs={'%dialog'};
    btnGenerate.ArgDataTypes={'handle'};
    btnGenerate.Tag=[tag_prefix,'generateCodeButton'];
    btnGenerate.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSCreateButtonTooltip');


    btnCancel.Type='pushbutton';
    btnCancel.Mode=1;
    btnCancel.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSCancelButtonLabel');
    btnCancel.RowSpan=[1,1];
    btnCancel.ColSpan=[4,4];
    btnCancel.ObjectMethod='cancel';
    btnCancel.MethodArgs={'%dialog'};
    btnCancel.Source=obj;
    btnCancel.ArgDataTypes={'handle'};
    btnCancel.Tag=[tag_prefix,'cancelButton'];
    btnCancel.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSCancelButtonTooltip');


    btnHelp.Type='pushbutton';
    btnHelp.Mode=1;
    btnHelp.Graphical=1;
    btnHelp.Name=DAStudio.message('FMUExport:FMU:FMU2ExpCSHelpButtonLabel');
    btnHelp.RowSpan=[1,1];
    btnHelp.ColSpan=[5,5];
    btnHelp.ObjectMethod='help';
    btnHelp.Source=obj;
    btnHelp.Tag=[tag_prefix,'helpButton'];
    btnHelp.ToolTip=DAStudio.message('FMUExport:FMU:FMU2ExpCSHelpButtonTooltip');


    pnlButton.Type='panel';
    pnlButton.LayoutGrid=[1,5];
    pnlButton.ColStretch=[0,0,0,0,0];
    pnlButton.Items={btnGenerate,btnHelp,btnCancel};


    schema.DialogTitle=DAStudio.message('FMUExport:FMU:FMU2ExpCSDialogTitle',obj.ModelName);
    schema.DialogTag=[tag_prefix,'dialog'];

    schema.StandaloneButtonSet=pnlButton;
    schema.IsScrollable=true;
    schema.Items={grpFMU2ExpCSDescription,grpContents,grpContentsOptions};
end



