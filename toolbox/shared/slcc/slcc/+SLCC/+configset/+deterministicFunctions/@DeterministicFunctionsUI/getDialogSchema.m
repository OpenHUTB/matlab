function dlgstruct=getDialogSchema(dlgSrc,~)





    iconPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources');


    descriptionText.Type='text';
    descriptionText.Name=getString(message('Simulink:CustomCode:DeterministicFunctionsDlgDescription'));
    descriptionText.Tag=[dlgSrc.tagPrefix,'Description_Text'];
    descriptionText.WordWrap=true;

    descriptionGroup.Type='group';
    descriptionGroup.Name=getString(message('Simulink:CustomCode:DeterministicFunctionsDlgDescriptionTitle'));
    descriptionGroup.Items={descriptionText};

    customizeSettingLayoutGrid=[3,10];

    addFcn.Type='pushbutton';
    addFcn.Tag=[dlgSrc.tagPrefix,'Add_Function_Button'];
    addFcn.ToolTip=getString(message('Simulink:CustomCode:DeterministicFunctionsDlgAddButtonTooltip'));
    addFcn.FilePath=fullfile(iconPath,'add.png');
    addFcn.RowSpan=[2,2];
    addFcn.ColSpan=[1,1];
    addFcn.ObjectMethod='customizeAddCallBack';
    addFcn.DialogRefresh=1;

    deleteFcn.Type='pushbutton';
    deleteFcn.Tag=[dlgSrc.tagPrefix,'Delete_Function_Button'];
    deleteFcn.ToolTip=getString(message('Simulink:CustomCode:DeterministicFunctionsDlgDeleteButtonTooltip'));
    deleteFcn.FilePath=fullfile(iconPath,'delete.gif');
    deleteFcn.RowSpan=[2,2];
    deleteFcn.ColSpan=[2,2];
    deleteFcn.ObjectMethod='customizeDeleteCallBack';
    deleteFcn.DialogRefresh=1;

    functionSettingSS=getDeterministicFunctionsSpreadsheetSchema(dlgSrc,customizeSettingLayoutGrid);

    customizeSettingsPanel.Type='group';
    customizeSettingsPanel.Items={addFcn,deleteFcn,functionSettingSS};
    customizeSettingsPanel.LayoutGrid=customizeSettingLayoutGrid;
    customizeSettingsPanel.RowStretch=[0,0,1];
    customizeSettingsPanel.ColStretch=[0,0,ones(1,customizeSettingLayoutGrid(2)-2)];

    dlgstruct.DialogTitle=getString(message('Simulink:CustomCode:DeterministicFunctionsDlgTitle'));
    dlgstruct.Items={descriptionGroup,customizeSettingsPanel};
    dlgstruct.PreApplyMethod='preApplyCallBack';
    dlgstruct.HelpMethod='helpCallBack';
end

function ssWidget=getDeterministicFunctionsSpreadsheetSchema(dlgSrc,parentGrid)
    import SLCC.configset.deterministicFunctions.DeterministicFunctionsSS
    colName={getString(message('Simulink:CustomCode:DeterministicFunctionsDlgSSFcnNameColHeader'))};

    ssWidget.Type='spreadsheet';
    ssWidget.Tag=[dlgSrc.tagPrefix,'Spreadsheet_Widget'];
    ssWidget.Columns=colName;
    ssWidget.RowSpan=[parentGrid(1),parentGrid(1)];
    ssWidget.ColSpan=[1,parentGrid(2)];
    ssWidget.Source=dlgSrc.fcnSettingsSS;
    ssWidget.SelectionChangedCallback=...
    @(tag,sels,dlg)dlgSrc.fcnSettingsSS.handleSelectionChanged(tag,sels,dlg);
end
