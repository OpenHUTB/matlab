function dlgStruct=getHardwareNodeDialogSchema(h,name)%#ok




    if isa(h,'Simulink.DistributedTarget.HardwareNode')
        obj=h;
    elseif isa(h,"DAStudio.DAObjectProxy")
        obj=h.getMCOSObjectReference();
    else
        obj=h;
    end



    isReadOnly=false;





    descGroup.Name=DAStudio.message('Simulink:taskEditor:PropertiesGroupText');
    descGroup.Type='group';
    descGroup.Items={};


    hwNodeNameEditTxt.Name=DAStudio.message('Simulink:taskEditor:NameText');
    hwNodeNameEditTxt.Type='text';

    hwNodeNameEdit.Name='';
    hwNodeNameEdit.Type='edit';
    hwNodeNameEdit.ObjectProperty='Name';
    hwNodeNameEdit.Source=h;
    hwNodeNameEdit.Tag='hwNodeNameEdit_tag';
    hwNodeNameEditTxt.Buddy=hwNodeNameEdit.Tag;


    hwNodeClockFreqEditTxt.Name=DAStudio.message('Simulink:taskEditor:ClockFrequencyText');
    hwNodeClockFreqEditTxt.Type='text';

    hwNodeClockFreqEdit.Name='';
    hwNodeClockFreqEdit.Type='edit';
    hwNodeClockFreqEdit.ObjectProperty='ClockFrequency';
    hwNodeClockFreqEdit.Source=h;
    hwNodeClockFreqEdit.Tag='hwNodeClockFreqEdit_tag';
    hwNodeClockFreqEditTxt.Buddy=hwNodeClockFreqEdit.Tag;


    hwNodeColorLabel.Name=DAStudio.message('Simulink:taskEditor:ColorText');
    hwNodeColorLabel.Type='text';
    hwNodeColorLabel.Enabled=1;
    hwNodeColorLabel.Tag='hwNodeColorLabel_tag';
    hwNodeColorLabel.Buddy=hwNodeColorLabel.Tag;

    hwNodeColorButton.Name='';
    hwNodeColorButton.Type='pushbutton';
    hwNodeColorButton.Enabled=true;
    hwNodeColorButton.Tag='colorButton';
    hwNodeColorButton.MatlabMethod='DeploymentDiagram.colorUtil';
    hwNodeColorButton.MatlabArgs={'openColorDlgWithoutExplorer',obj};
    hwNodeColorButton.DialogRefresh=1;
    hwNodeColorButton.MinimumSize=[37,26];
    hwNodeColorButton.MaximumSize=[37,26];
    hwNodeColorButton.FilePath=...
    DeploymentDiagram.colorUtil('getIconPath');
    hwNodeColorButton.BackgroundColor=255*(h.Color);

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',2,{...
    hwNodeNameEditTxt,hwNodeNameEdit,...
    hwNodeClockFreqEditTxt,hwNodeClockFreqEdit,...
    hwNodeColorLabel,hwNodeColorButton});

    descGroup.Items=indexedItems;
    descGroup.LayoutGrid=layout;

    title=[DAStudio.message('Simulink:taskEditor:HardwareNodeTitleText'),' ',h.Name];

    items=[{descGroup}...
    ,DeploymentDiagram.getCodeGenerationSubSchema(obj)];

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',1,items);

    dlgStruct.DialogTitle=title;
    dlgStruct.Items=indexedItems;
    dlgStruct.DisableDialog=isReadOnly;
    dlgStruct.LayoutGrid=layout;
    dlgStruct.RowStretch=[zeros(1,length(items)),1];
    dlgStruct.ColStretch=1;
    dlgStruct.Source=h;
    dlgStruct.HelpMethod='helpview';
    mapId=['mapkey:',class(h)];
    dlgStruct.HelpArgs={mapId,'help_button','CSHelpWindow'};

