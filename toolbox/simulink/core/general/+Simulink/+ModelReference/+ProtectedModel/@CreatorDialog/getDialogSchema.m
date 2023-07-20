function schema=getDialogSchema(obj)





    import Simulink.ModelReference.ProtectedModel.*;
    tag_prefix='protectedMdl_';



    lblDescription.Type='text';
    lblDescription.Name=DAStudio.message('Simulink:protectedModel:lblProtectedDlgDescription');
    lblDescription.RowSpan=[1,1];
    lblDescription.ColSpan=[1,1];
    lblDescription.Tag=[tag_prefix,'Description'];
    lblDescription.WordWrap=true;

    grpProtectedModelDescription.Type='group';
    grpProtectedModelDescription.Name=DAStudio.message('Simulink:protectedModel:grpDescription');
    grpProtectedModelDescription.LayoutGrid=[1,1];
    items={lblDescription};

    grpProtectedModelDescription.Items=items;


    enableView=isWebviewFeatureEnabled(obj.ReportGenLicense);
    enableSim=true;
    enableCG=isCodeGenFeatureEnabled;
    enableHDL=isHDLCodeGenFeatureEnabled;
    items={};
    rowCounter=1;

    if enableView

        viewSupport.Type='checkbox';
        viewSupport.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelViewLbl');
        viewSupport.RowSpan=[rowCounter,rowCounter];
        viewSupport.ColSpan=[1,1];
        viewSupport.Mode=1;
        viewSupport.Graphical=1;
        viewSupport.Source=obj;
        viewSupport.ObjectMethod='updateWebviewSupport';
        viewSupport.Value=false;
        viewSupport.MethodArgs={'%dialog'};
        viewSupport.ArgDataTypes={'handle'};
        viewSupport.Tag=[tag_prefix,'ProtectedModelWebview'];
        viewSupport.ToolTip=DAStudio.message('Simulink:protectedModel:chkProtectedModelWebviewToolTip');

        items=[items,{viewSupport}];
        rowCounter=rowCounter+1;
    end

    if enableSim

        simulationSupport.Type='checkbox';
        simulationSupport.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelSimulationLbl');
        simulationSupport.RowSpan=[rowCounter,rowCounter];
        simulationSupport.ColSpan=[1,1];
        simulationSupport.Mode=1;
        simulationSupport.Value=true;
        simulationSupport.Graphical=1;
        simulationSupport.Source=obj;
        simulationSupport.ObjectMethod='updateSimulationSupport';
        simulationSupport.MethodArgs={'%dialog'};
        simulationSupport.ArgDataTypes={'handle'};
        simulationSupport.Tag=[tag_prefix,'SimulationOnly'];
        simulationSupport.ToolTip=DAStudio.message('Simulink:protectedModel:chkSimulationOnlyToolTip');
        items=[items,{simulationSupport}];
        rowCounter=rowCounter+1;
    end




    if enableCG
        targetSupport.Type='checkbox';
        targetSupport.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelCodeGenerationLbl');
        targetSupport.RowSpan=[rowCounter,rowCounter];
        targetSupport.ColSpan=[1,1];
        targetSupport.Mode=1;
        targetSupport.Graphical=1;
        targetSupport.Source=obj;
        targetSupport.Value=false;
        targetSupport.ObjectMethod='updateCodegenSupport';
        targetSupport.MethodArgs={'%dialog'};
        targetSupport.ArgDataTypes={'handle'};
        targetSupport.Tag=[tag_prefix,'CodeGenSupport'];
        targetSupport.ToolTip=DAStudio.message('Simulink:protectedModel:chkAddSupportForCodeGenToolTip');
        items=[items,{targetSupport}];
        rowCounter=rowCounter+1;

        if obj.IsCodeInterfaceFeatureAvailable

            dropdownCodeInterface.Type='combobox';
            dropdownCodeInterface.Entries=[{DAStudio.message('Simulink:modelReference:CodeInterfaceMdlref')};...
            {DAStudio.message('Simulink:modelReference:CodeInterfaceTop')}];
            dropdownCodeInterface.RowSpan=[rowCounter,rowCounter];
            dropdownCodeInterface.ColSpan=[1,3];
            dropdownCodeInterface.Enabled=false;
            dropdownCodeInterface.Mode=1;
            if obj.IsAUTOSARModel

                dropdownCodeInterface.Value=1;
            else

                dropdownCodeInterface.Value=0;
            end
            dropdownCodeInterface.Graphical=1;
            dropdownCodeInterface.Name=['     ',DAStudio.message('Simulink:protectedModel:lblPackagedCodeInterface'),'    '];
            dropdownCodeInterface.Tag=[tag_prefix,'ProtectedModelCodeInterface'];
            dropdownCodeInterface.ToolTip=DAStudio.message('Simulink:protectedModel:dropdownProtectedModelCodeInterfaceTooltip');
            items=[items,{dropdownCodeInterface}];
            rowCounter=rowCounter+1;

        end


        dropdownContents.Type='combobox';
        dropdownContents.Entries=[{DAStudio.message('Simulink:protectedModel:ProtectedModelContentsBinaries')};...
        {DAStudio.message('Simulink:protectedModel:ProtectedModelContentsObfuscatedSourceCode')};...
        {DAStudio.message('Simulink:protectedModel:ProtectedModelContentsSourceCode')}];
        dropdownContents.RowSpan=[rowCounter,rowCounter];
        dropdownContents.ColSpan=[1,3];
        dropdownContents.Enabled=false;
        dropdownContents.Mode=1;
        dropdownContents.Graphical=1;
        dropdownContents.Name=['     ',DAStudio.message('Simulink:protectedModel:lblPackagedArtifactType'),'    '];
        dropdownContents.Tag=[tag_prefix,'ProtectedModelContents'];
        dropdownContents.ToolTip=DAStudio.message('Simulink:protectedModel:dropdownProtectedModelContentsTooltip');
        items=[items,{dropdownContents}];
        rowCounter=rowCounter+1;
    end




    if enableHDL
        hdlSupport.Type='checkbox';
        hdlSupport.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelHDLCodeGenerationLbl');
        hdlSupport.RowSpan=[rowCounter,rowCounter];
        hdlSupport.ColSpan=[1,1];
        hdlSupport.Mode=1;
        hdlSupport.Graphical=1;
        hdlSupport.Source=obj;
        hdlSupport.Value=false;
        hdlSupport.ObjectMethod='updateHDLCodegenSupport';
        hdlSupport.MethodArgs={'%dialog'};
        hdlSupport.ArgDataTypes={'handle'};
        hdlSupport.Tag=[tag_prefix,'HDLCodeGenSupport'];
        hdlSupport.ToolTip=DAStudio.message('Simulink:protectedModel:chkAddSupportForHDLCodeGenToolTip');
        items=[items,{hdlSupport}];
        rowCounter=rowCounter+1;
    end


    [passwordItems1,passwordHDL,numRows]=getPasswordEntrySchema(enableSim,...
    enableCG,...
    enableHDL,...
    enableView,...
    false,...
    tag_prefix,...
    'createFromGUI',...
    obj.ModelName);

    if enableHDL
        numRows=numRows-1;
    end

    grpPasswords1.Type='panel';
    grpPasswords1.Visible=true;
    grpPasswords1.Tag=[tag_prefix,'Passwords'];
    grpPasswords1.Items=passwordItems1;
    grpPasswords1.LayoutGrid=[numRows,2];
    grpPasswords1.RowSpan=[1,numRows];
    grpPasswords1.ColSpan=[2,3];
    items=[items,{grpPasswords1}];


    if enableHDL
        grpPasswords2.Type='panel';
        grpPasswords2.Visible=true;
        grpPasswords2.Tag=[tag_prefix,'HDLPasswords'];
        grpPasswords2.Items=passwordHDL;
        grpPasswords2.LayoutGrid=[1,2];
        grpPasswords2.RowSpan=[rowCounter-1,rowCounter-1];
        grpPasswords2.ColSpan=[2,3];
        items=[items,{grpPasswords2}];
    end


    grpContents.Type='group';
    grpContents.Visible=true;
    grpContents.Name=DAStudio.message('Simulink:protectedModel:grpCapabilities');
    grpContents.Tag=[tag_prefix,'PackageOptions'];
    grpContents.ColStretch=[5,11,7];
    grpContents.LayoutGrid=[rowCounter+1,3];

    grpContents.Items=items;

    if slfeature('ProtectedModelTunableParameters')

        paramDesc.Type='text';
        paramDesc.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelTunableParameterDes');
        paramDesc.RowSpan=[1,1];
        paramDesc.ColSpan=[1,8];
        paramDesc.Tag=[tag_prefix,'paramDesc'];

        filterEdit.Type='spreadsheetfilter';
        filterEdit.Tag=[tag_prefix,'filterEdit'];
        filterEdit.RowSpan=[2,2];
        filterEdit.ColSpan=[1,7];
        filterEdit.TargetSpreadsheet=[tag_prefix,'paramList'];
        filterEdit.PlaceholderText=DAStudio.message('Simulink:protectedModel:ProtectedModelFileterParameterTxt');
        filterEdit.Clearable=true;


        paramList.Type='spreadsheet';
        paramList.Columns={DAStudio.message('Simulink:protectedModel:ProtectedModelParameterNameColumn');...
        DAStudio.message('Simulink:protectedModel:ProtectedModelParameterTunableColumn');...
        DAStudio.message('Simulink:protectedModel:ProtectedModelParameterSourceColumn');};
        paramList.SortColumn=DAStudio.message('Simulink:protectedModel:ProtectedModelParameterNameColumn');
        paramList.SortOrder=true;
        paramList.RowSpan=[3,3];
        paramList.ColSpan=[1,7];
        paramList.Tag=[tag_prefix,'paramList'];
        paramList.DialogRefresh=false;
        paramList.Hierarchical=false;
        paramList.Source=obj.paramListSource;
        paramList.Config='{"expandall": true, "enablemultiselect" : true, "emptyparentinfiltermode" : false}';


        selectAllButton.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelSelcetAllBtn');
        selectAllButton.Type='pushbutton';
        selectAllButton.Enabled=1;
        selectAllButton.RowSpan=[4,4];
        selectAllButton.ColSpan=[6,6];
        selectAllButton.Tag=[tag_prefix,'selectAll'];
        selectAllButton.Source=obj;
        selectAllButton.ObjectMethod='selectAll';
        selectAllButton.MethodArgs={'%dialog'};
        selectAllButton.ArgDataTypes={'handle'};
        selectAllButton.ToolTip=DAStudio.message('Simulink:protectedModel:ProtectedModelSelcetAllBtnTooltip');


        unselectButton.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelUnSelcetAllBtn');
        unselectButton.Type='pushbutton';
        unselectButton.Enabled=1;
        unselectButton.RowSpan=[4,4];
        unselectButton.ColSpan=[7,7];
        unselectButton.Tag=[tag_prefix,'unselectAll'];
        unselectButton.Source=obj;
        unselectButton.ObjectMethod='unselectAll';
        unselectButton.MethodArgs={'%dialog'};
        unselectButton.ArgDataTypes={'handle'};
        unselectButton.ToolTip=DAStudio.message('Simulink:protectedModel:ProtectedModelUnSelcetAllBtnTooltip');



        grpParameter.Type='togglepanel';
        grpParameter.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelTunableParameterPanel');
        grpParameter.LayoutGrid=[1,2];
        items={paramDesc,filterEdit,paramList,selectAllButton,unselectButton};
        grpParameter.Items=items;
    end



    editPackagePath.Type='edit';
    editPackagePath.Name=DAStudio.message('Simulink:protectedModel:lblPackagePath');
    editPackagePath.RowSpan=[1,1];
    editPackagePath.ColSpan=[1,4];
    editPackagePath.Mode=1;
    editPackagePath.Graphical=1;
    editPackagePath.Value=pwd;
    editPackagePath.Tag=[tag_prefix,'PackagePath'];
    editPackagePath.ToolTip=DAStudio.message('Simulink:protectedModel:edtPackagePathToolTip');


    packagePathBrowse.Type='pushbutton';
    packagePathBrowse.Name=DAStudio.message('Simulink:protectedModel:btnBrowse');
    packagePathBrowse.RowSpan=[1,1];
    packagePathBrowse.ColSpan=[5,5];
    packagePathBrowse.Mode=1;
    packagePathBrowse.Graphical=1;
    packagePathBrowse.Source=obj;
    packagePathBrowse.ObjectMethod='browseReportLocation';
    packagePathBrowse.MethodArgs={'%dialog'};
    packagePathBrowse.ArgDataTypes={'handle'};
    packagePathBrowse.Tag=[tag_prefix,'BrowseOutputDirButton'];
    packagePathBrowse.ToolTip=DAStudio.message('Simulink:protectedModel:btnBrowseToolTip');


    createHarness.Type='checkbox';
    createHarness.Name=DAStudio.message('Simulink:protectedModel:lblCreateHarness');
    createHarness.RowSpan=[3,3];
    createHarness.ColSpan=[1,2];
    createHarness.Mode=1;
    createHarness.Graphical=1;
    createHarness.Enabled=false;
    createHarness.Value=true;
    createHarness.Source=obj;
    createHarness.Tag=[tag_prefix,'CreateHarness'];
    createHarness.ToolTip=DAStudio.message('Simulink:protectedModel:chkCreateHarnessToolTip');


    cbSaveOption.Name=DAStudio.message('Simulink:protectedModel:cbSaveOption');
    cbSaveOption.Type='combobox';
    cbSaveOption.Tag=[tag_prefix,'SaveOption'];
    cbSaveOption.Entries=[{DAStudio.message('Simulink:protectedModel:cbSaveOptionItem1')};...
    {DAStudio.message('Simulink:protectedModel:cbSaveOptionItem2')}];
    cbSaveOption.Mode=1;
    cbSaveOption.Graphical=1;
    cbSaveOption.RowSpan=[2,2];
    cbSaveOption.ColSpan=[1,4];
    cbSaveOption.Value=1;
    cbSaveOption.MethodArgs={'%dialog'};
    cbSaveOption.ArgDataTypes={'handle'};
    cbSaveOption.ObjectMethod='updateSaveOption';
    cbSaveOption.ToolTip=DAStudio.message('Simulink:protectedModel:dropdownSaveOptionsToolTip');


    editProjectName.Name=DAStudio.message('Simulink:protectedModel:editProjectName');
    editProjectName.Type='edit';
    editProjectName.RowSpan=[4,4];
    editProjectName.ColSpan=[1,4];
    editProjectName.Mode=1;
    editProjectName.Graphical=1;
    editProjectName.Enabled=true;
    editProjectName.Value=[obj.ModelName,'_protected'];
    editProjectName.Tag=[tag_prefix,'ProjectName'];
    editProjectName.ToolTip=DAStudio.message('Simulink:protectedModel:editProjectNameToolTip');


    grpProtectedModelSaving.Type='group';
    grpProtectedModelSaving.Name=DAStudio.message('Simulink:protectedModel:grpSaving');
    grpProtectedModelSaving.LayoutGrid=[1,5];
    items={cbSaveOption,editProjectName,editPackagePath,packagePathBrowse,createHarness};
    grpProtectedModelSaving.Items=items;



    pnlProtectedModelGeneral.Type='panel';
    pnlProtectedModelGeneral.LayoutGrid=[1,1];
    if(slfeature('ProtectedModelDirectSimulation')>1)
        items={};
    else
        editPackagePath.RowSpan=[1,1];
        packagePathBrowse.RowSpan=[1,1];
        createHarness.RowSpan=[3,3];
        createHarness.ColSpan=[1,2];
        items={editPackagePath,packagePathBrowse,createHarness};
    end

    pnlProtectedModelGeneral.Items=items;


    btnGenerate.Type='pushbutton';
    btnGenerate.RowSpan=[1,1];
    btnGenerate.ColSpan=[3,3];
    btnGenerate.Mode=1;
    btnGenerate.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelCreateBtn');
    btnGenerate.ObjectMethod='generate';
    btnGenerate.Source=obj;
    btnGenerate.MethodArgs={'%dialog'};
    btnGenerate.ArgDataTypes={'handle'};
    btnGenerate.Tag=[tag_prefix,'generateCodeButton'];


    btnCancel.Type='pushbutton';
    btnCancel.Mode=1;
    btnCancel.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelCancelBtn');
    btnCancel.RowSpan=[1,1];
    btnCancel.ColSpan=[4,4];
    btnCancel.ObjectMethod='cancel';
    btnCancel.MethodArgs={'%dialog'};
    btnCancel.Source=obj;
    btnCancel.ArgDataTypes={'handle'};
    btnCancel.Tag=[tag_prefix,'cancelButton'];


    btnHelp.Type='pushbutton';
    btnHelp.Mode=1;
    btnHelp.Graphical=1;
    btnHelp.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelHelpBtn');
    btnHelp.RowSpan=[1,1];
    btnHelp.ColSpan=[5,5];
    btnHelp.ObjectMethod='help';
    btnHelp.Source=obj;
    btnHelp.Tag=[tag_prefix,'helpButton'];


    pnlButton.Type='panel';
    pnlButton.LayoutGrid=[1,5];
    pnlButton.ColStretch=[0,0,0,0,0];
    pnlButton.Items={btnGenerate,btnHelp,btnCancel};


    schema.DialogTitle=DAStudio.message('Simulink:protectedModel:ProtectedMdlOptsDlgTitle',obj.ModelName);
    schema.DialogTag=[tag_prefix,'dialog'];

    schema.StandaloneButtonSet=pnlButton;
    schema.IsScrollable=true;
    if(slfeature('ProtectedModelDirectSimulation')<2)
        schema.Items={grpProtectedModelDescription,grpContents,pnlProtectedModelGeneral};
    else
        if slfeature('ProtectedModelTunableParameters')
            schema.Items={grpProtectedModelDescription,grpContents,pnlProtectedModelGeneral,grpParameter,grpProtectedModelSaving};
        else
            schema.Items={grpProtectedModelDescription,grpContents,pnlProtectedModelGeneral,grpProtectedModelSaving};
        end
    end
end

