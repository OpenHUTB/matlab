function ret=getDataAccessTab(~)




    curRow=1;


    lblCBUsage.Tag='lblCBUsage';
    lblCBUsage.Type='text';
    lblCBUsage.WordWrap=1;
    lblCBUsage.Name=getString(message('SDI:dialogs:DataAccessUsage'));
    lblCBUsage.RowSpan=[1,1];

    groupCBUsage.Type='group';
    groupCBUsage.Tag='groupCallbackUsage';
    groupCBUsage.Name=getString(message('SDI:dialogs:DataAccessGroupUsage'));
    groupCBUsage.RowSpan=[curRow,curRow];
    groupCBUsage.ColSpan=[1,2];
    groupCBUsage.LayoutGrid=[1,1];
    groupCBUsage.Items={lblCBUsage};
    curRow=curRow+1;


    enableDataAccessCheck.Tag='chkBoxEnable';
    enableDataAccessCheck.Type='checkbox';
    enableDataAccessCheck.Name=getString(message('SDI:dialogs:DataAccessEnable'));
    enableDataAccessCheck.ToolTip=getString(message('SDI:dialogs:DataAccessEnableTooltip'));
    enableDataAccessCheck.Value=1;
    enableDataAccessCheck.ObjectMethod='dataAccessSettingCB';
    enableDataAccessCheck.MethodArgs={'%dialog'};
    enableDataAccessCheck.ArgDataTypes={'handle'};
    enableDataAccessCheck.RowSpan=[curRow,curRow];
    enableDataAccessCheck.ColSpan=[1,1];
    curRow=curRow+1;


    lblFcnCallback.Tag='lblFcnCallback';
    lblFcnCallback.Type='text';
    lblFcnCallback.Name=getString(message('SDI:dialogs:DataAccessFcnLabel'));
    lblFcnCallback.ToolTip=getString(message('SDI:dialogs:DataAccessFcnTooltip'));
    lblFcnCallback.RowSpan=[curRow,curRow];
    lblFcnCallback.ColSpan=[1,1];

    txtFcnCallback.Tag='txtFcnCallback';
    txtFcnCallback.Type='edit';
    txtFcnCallback.RowSpan=[curRow,curRow];
    txtFcnCallback.ColSpan=[2,2];
    curRow=curRow+1;


    lblTime.Tag='lblTime';
    lblTime.Type='text';
    lblTime.Name=getString(message('SDI:dialogs:DataAccessTimeChkBoxLabel'));
    lblTime.ToolTip=getString(message('SDI:dialogs:DataAccessTimeChkBoxTooltip'));
    lblTime.RowSpan=[curRow,curRow];
    lblTime.ColSpan=[1,1];

    chkBoxTime.Tag='chkBoxTime';
    chkBoxTime.Type='checkbox';
    chkBoxTime.RowSpan=[curRow,curRow];
    chkBoxTime.ColSpan=[2,2];
    chkBoxTime.Value=1;
    curRow=curRow+1;


    lblFcnParams.Tag='lblFcnParams';
    lblFcnParams.Type='text';
    lblFcnParams.Name=getString(message('SDI:dialogs:DataAccessParamsLabel'));
    lblFcnParams.ToolTip=getString(message('SDI:dialogs:DataAccessParamsTooltip'));
    lblFcnParams.RowSpan=[curRow,curRow];
    lblFcnParams.ColSpan=[1,1];

    txtFcnParam.Tag='txtFcnParam';
    txtFcnParam.Type='edit';
    txtFcnParam.PlaceholderText='optional';
    txtFcnParam.RowSpan=[curRow,curRow];
    txtFcnParam.ColSpan=[2,2];
    curRow=curRow+1;


    CallbackFcnSettingsGroup.Tag='dataAccessSettingsGroup';
    CallbackFcnSettingsGroup.Type='group';
    CallbackFcnSettingsGroup.LayoutGrid=[6,2];
    CallbackFcnSettingsGroup.RowStretch=[0,0,0,0,0,1];
    CallbackFcnSettingsGroup.Items={...
    groupCBUsage,...
    enableDataAccessCheck,...
    lblFcnCallback,txtFcnCallback,...
    lblFcnParams,txtFcnParam,...
    lblTime,chkBoxTime...
    };

    ret.Name=getString(message('SDI:dialogs:SigSettingsDataAccessTab'));
    ret.Items={CallbackFcnSettingsGroup};

end