function tab=getTolerancesTab(this)



    if~Simulink.sdi.enableTolerancesDataEntry
        tab=[];
        return
    end

    [blockPath,portIndex]=this.elaborateContext();


    lblTolUsage.Tag='lblTolUsage';
    lblTolUsage.Type='text';
    lblTolUsage.WordWrap=1;
    lblTolUsage.Name=getString(message('SDI:dialogs:ToleranceUsage'));
    lblTolUsage.RowSpan=[1,1];
    lblTolUsage.ColSpan=[1,1];

    groupTolUsage.Type='group';
    groupTolUsage.Tag='groupTolUsage';
    groupTolUsage.Name=getString(message('SDI:dialogs:ToleranceGroupUsage'));
    groupTolUsage.RowSpan=[1,1];
    groupTolUsage.ColSpan=[1,2];

    groupTolUsage.LayoutGrid=[1,1];
    groupTolUsage.Items={lblTolUsage};


    lblAbsoluteTolerance.Tag='lblAbsoluteTolerance';
    lblAbsoluteTolerance.Type='text';
    lblAbsoluteTolerance.Name=getString(message('SDI:dialogs:ToleranceAbsLabel'));
    lblAbsoluteTolerance.ToolTip=getString(message('SDI:dialogs:ToleranceAbsTooltip'));
    lblAbsoluteTolerance.RowSpan=[2,2];
    lblAbsoluteTolerance.ColSpan=[1,1];

    txtAbsoluteTolerance.Tag='txtAbsoluteTolerance';
    txtAbsoluteTolerance.Type='edit';
    txtAbsoluteTolerance.ObjectMethod='loggingSettingChangeCB';
    txtAbsoluteTolerance.MethodArgs={'%dialog'};
    txtAbsoluteTolerance.ArgDataTypes={'handle'};
    txtAbsoluteTolerance.RowSpan=[2,2];
    txtAbsoluteTolerance.ColSpan=[2,2];
    txtAbsoluteTolerance.PlaceholderText=getString(message('SDI:dialogs:ToleranceAbsPlaceholder'));
    str=sprintf('%.2f',Simulink.sdi.internal.Utils.getToleranceFromModel(blockPath,portIndex,'AbsTol'));
    if~isempty(str)
        txtAbsoluteTolerance.Value=str;
    end


    lblRelativeTolerance.Tag='lblRelativeTolerance';
    lblRelativeTolerance.Type='text';
    lblRelativeTolerance.Name=getString(message('SDI:dialogs:ToleranceRelLabel'));
    lblRelativeTolerance.ToolTip=getString(message('SDI:dialogs:ToleranceRelTooltip'));
    lblRelativeTolerance.RowSpan=[3,3];
    lblRelativeTolerance.ColSpan=[1,1];

    txtRelativeTolerance.Tag='txtRelativeTolerance';
    txtRelativeTolerance.Type='edit';
    txtRelativeTolerance.ObjectMethod='loggingSettingChangeCB';
    txtRelativeTolerance.MethodArgs={'%dialog'};
    txtRelativeTolerance.ArgDataTypes={'handle'};
    txtRelativeTolerance.RowSpan=[3,3];
    txtRelativeTolerance.ColSpan=[2,2];
    txtRelativeTolerance.PlaceholderText=getString(message('SDI:dialogs:ToleranceAbsPlaceholder'));
    str=sprintf('%.2f',Simulink.sdi.internal.Utils.getToleranceFromModel(blockPath,portIndex,'RelTol'));
    if~isempty(str)
        txtRelativeTolerance.Value=str;
    end


    tolGroup.Tag='callbackTolerances';
    tolGroup.Type='group';
    tolGroup.LayoutGrid=[4,2];
    tolGroup.RowStretch=[0,0,0,1];
    tolGroup.Items={...
    groupTolUsage,...
    lblAbsoluteTolerance,txtAbsoluteTolerance,...
    lblRelativeTolerance,txtRelativeTolerance...
    };

    tab.Name=getString(message('SDI:dialogs:SigSettingsTolerancesTab'));
    tab.Items={tolGroup};
end
