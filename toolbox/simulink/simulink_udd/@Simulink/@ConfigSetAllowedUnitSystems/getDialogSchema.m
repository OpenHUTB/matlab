function hDlg=getDialogSchema(hObj,schema)%#ok



    tag='Tag_AllowedUnitSystems_';


    descText.Name=DAStudio.message('Simulink:dialog:SL_DSCPT_UNITCONFIG');
    descText.Type='text';
    descText.WordWrap=true;
    descText.RowSpan=[1,1];
    descText.ColSpan=[1,3];

    descGroup.Name=DAStudio.message('Simulink:dialog:UnitConfigurationDescTitle');
    descGroup.Type='group';
    descGroup.Items={descText};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];
    descGroup.LayoutGrid=[1,3];
    descGroup.RowStretch=0;
    descGroup.ColStretch=[0,0,1];


    unitSystemSchema=getAllowedUnitSystemsDialogSchema(hObj);

    paramGroup.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGroup.Type='group';
    paramGroup.Items=unitSystemSchema.Items;
    paramGroup.LayoutGrid=[5,3];
    paramGroup.RowStretch=[zeros(1,4),1];
    paramGroup.ColStretch=[1,0,1];
    paramGroup.RowSpan=[2,2];
    paramGroup.ColSpan=[1,3];



    OK.Name=DAStudio.message('Simulink:dialog:DCDOK');
    OK.Type='pushbutton';
    OK.Tag=[tag,'OKButton'];
    OK.ObjectMethod='OKCallback';
    OK.MethodArgs={'%dialog'};
    OK.ArgDataTypes={'handle'};
    OK.DialogRefresh=1;
    OK.Source=hObj;
    OK.RowSpan=[1,1];
    OK.ColSpan=[2,2];



    cancel.Name=DAStudio.message('Simulink:dialog:DCDCancel');
    cancel.Type='pushbutton';
    cancel.Tag=[tag,'CancelButton'];
    cancel.ObjectMethod='CancelCallback';
    cancel.MethodArgs={'%dialog'};
    cancel.ArgDataTypes={'handle'};
    cancel.DialogRefresh=1;
    cancel.Source=hObj;
    cancel.RowSpan=[1,1];
    cancel.ColSpan=[3,3];



    help.Name=DAStudio.message('Simulink:dialog:DCDHelp');
    help.Type='pushbutton';
    help.Tag=[tag,'Help'];
    help.ObjectMethod='helpCallback';
    help.MethodArgs={'%dialog'};
    help.ArgDataTypes={'handle'};
    help.DialogRefresh=1;
    help.Source=hObj;
    help.RowSpan=[1,1];
    help.ColSpan=[4,4];

    buttonGroup.Type='panel';
    buttonGroup.LayoutGrid=[1,4];
    buttonGroup.ColStretch=[1,0,0,0];
    buttonGroup.Items={OK,cancel,help};
    buttonGroup.RowSpan=[3,3];
    buttonGroup.ColSpan=[1,1];

    allowedUnitSysLGrp.LayoutGrid=[4,1];
    allowedUnitSysLGrp.RowStretch=[0,1,0,0];
    allowedUnitSysLGrp.Type='panel';
    allowedUnitSysLGrp.Items={descGroup,paramGroup,buttonGroup};



    hDlg.DialogTitle=DAStudio.message('Simulink:dialog:configSetAllowedUnitSystemsDialogTitle');
    hDlg.CloseMethod='CancelCallback';
    hDlg.CloseMethodArgs={'%dialog'};
    hDlg.CloseMethodArgsDT={'handle'};
    hDlg.LayoutGrid=[3,1];
    hDlg.Items={allowedUnitSysLGrp};
    hDlg.StandaloneButtonSet={''};
end


