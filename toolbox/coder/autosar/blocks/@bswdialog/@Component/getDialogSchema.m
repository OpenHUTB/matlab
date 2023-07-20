function dlgStruct=getDialogSchema(h,~)











    tagPrefix='tag_';

    maskObj=get_param(h.getBlock().handle,'MaskObject');

    bswCompPath=getfullname(h.getBlock().Handle);
    isDem=strcmp(autosar.bsw.ServiceComponent.getBswCompType(bswCompPath),'Dem');

    configurationRow=0;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Name=DAStudio.message('autosarstandard:ui:uiRTEDesc');
    widget.ToolTip=DAStudio.message('autosarstandard:ui:uiRTEDescTip');
    widget.Type='text';
    widget.WordWrap=true;
    widget.Tag=[tagPrefix,'MappingDescriptionLabel'];
    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    MappingDescriptionLabel=widget;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='spreadsheetfilter';
    widget.RowSpan=[configurationRow,configurationRow];
    widget.Tag=[tagPrefix,'MappingSpreadsheetFilter'];
    widget.TargetSpreadsheet=[tagPrefix,'MappingSpreadsheet'];
    widget.PlaceholderText=DAStudio.message('autosarstandard:ui:uiRTEFilterText');
    widget.Visible=true;
    widget.Clearable=true;
    MappingSpreadsheetFilter=widget;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='spreadsheet';
    if isDem
        widget.Columns={
        autosar.ui.bsw.ServiceComponentSpreadsheetRow.ClientPortColumn...
        ,autosar.ui.bsw.ServiceComponentSpreadsheetRow.IdColumn...
        ,autosar.ui.bsw.ServiceComponentSpreadsheetRow.IdTypeColumn
        };
    else
        widget.Columns={
        autosar.ui.bsw.ServiceComponentSpreadsheetRow.ClientPortColumn...
        ,autosar.ui.bsw.ServiceComponentSpreadsheetRow.BlockIdColumn...
        };
    end
    widget.SortColumn=autosar.ui.bsw.ServiceComponentSpreadsheetRow.ClientPortColumn;
    widget.SortOrder=true;
    widget.RowSpan=[configurationRow,configurationRow];
    widget.Enabled=true;
    widget.Source=autosar.ui.bsw.ServiceComponentSpreadsheet(h);
    widget.Tag=[tagPrefix,'MappingSpreadsheet'];
    widget.Visible=true;
    MappingSpreadsheet=widget;


    mappingcontainer.Type='panel';
    mappingcontainer.Tag=[tagPrefix,'mappingcontainer'];
    mappingcontainer.LayoutGrid=[configurationRow,2];

    mappingcontainer.ColSpan=[1,1];
    mappingcontainer.RowSpan=[1,1];
    mappingcontainer.Items={
MappingDescriptionLabel...
    ,MappingSpreadsheetFilter...
    ,MappingSpreadsheet};


    portconfigurationtab=[];
    portconfigurationtab.Name=DAStudio.message('autosarstandard:ui:uiRTETab');
    portconfigurationtab.Tag=[tagPrefix,'portconfigurationtab'];
    portconfigurationtab.LayoutGrid=[configurationRow,2];
    portconfigurationtab.Items={};
    portconfigurationtab.Items={
    mappingcontainer};

    configurationRow=0;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='text';
    widget.Name=DAStudio.message('autosarstandard:ui:uiDiagIncStepSizeText');
    widget.Tag=[tagPrefix,'IncrementStepSizeLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    IncrementStepSizeLabel=widget;


    widget=[];
    widget.Type='edit';
    widget.Source=h.getBlock();
    widget.ObjectProperty='DemDebounceCounterIncrementStepSize';
    widget.MatlabMethod='handleEditEvent';
    widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
    widget.Tag=widget.ObjectProperty;

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    IncrementStepSize=widget;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='text';
    widget.Name=DAStudio.message('autosarstandard:ui:uiDiagDecStepSizeText');
    widget.Tag=[tagPrefix,'DecrementStepSizeLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    DecrementStepSizeLabel=widget;


    widget=[];
    widget.Type='edit';
    widget.Source=h.getBlock();
    widget.ObjectProperty='DemDebounceCounterDecrementStepSize';
    widget.MatlabMethod='handleEditEvent';
    widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
    widget.Tag=widget.ObjectProperty;

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    DecrementStepSize=widget;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='text';
    widget.Name=DAStudio.message('autosarstandard:ui:uiDiagFailedThresholdText');
    widget.Tag=[tagPrefix,'FailedThresholdLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    FailedThresholdLabel=widget;


    widget=[];
    widget.Type='edit';
    widget.Source=h.getBlock();
    widget.ObjectProperty='DemDebounceCounterFailedThreshold';
    widget.MatlabMethod='handleEditEvent';
    widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
    widget.Tag=widget.ObjectProperty;

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    FailedThreshold=widget;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='text';
    widget.Name=DAStudio.message('autosarstandard:ui:uiDiagPassedThresholdText');
    widget.Tag=[tagPrefix,'PassedThresholdLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    PassedThresholdLabel=widget;


    widget=[];
    widget.Type='edit';
    widget.Source=h.getBlock();
    widget.ObjectProperty='DemDebounceCounterPassedThreshold';
    widget.MatlabMethod='handleEditEvent';
    widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
    widget.Tag=widget.ObjectProperty;

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    PassedThreshold=widget;

    paramsgroupRow=0;


    paramsgroupRow=paramsgroupRow+1;
    debouncecontainer.Type='group';
    debouncecontainer.Name=DAStudio.message('autosarstandard:ui:uiDiagDebounceDesc');
    debouncecontainer.Tag=[tagPrefix,'debouncecontainer'];

    debouncecontainer.LayoutGrid=[configurationRow+1,2];

    debouncecontainer.RowStretch=[zeros(1,configurationRow),1];

    debouncecontainer.ColSpan=[1,1];
    debouncecontainer.RowSpan=[paramsgroupRow,paramsgroupRow];
    debouncecontainer.Items={
IncrementStepSizeLabel...
    ,IncrementStepSize...
    ,DecrementStepSizeLabel...
    ,DecrementStepSize...
    ,FailedThresholdLabel...
    ,FailedThreshold...
    ,PassedThresholdLabel...
    ,PassedThreshold};

    configurationRow=0;


    configurationRow=configurationRow+1;
    widget=[];
    widget.Type='text';
    widget.Name=DAStudio.message('autosarstandard:ui:uiNVRAMMaxBlockId');
    widget.Tag=[tagPrefix,'MaxBlockIdLabel'];

    widget.ColSpan=[1,1];
    widget.RowSpan=[configurationRow,configurationRow];
    MaxBlockIdLabel=widget;


    widget=[];
    widget.Type='edit';
    widget.Source=h.getBlock();
    widget.ObjectProperty='MaxBlockId';
    widget.MatlabMethod='handleEditEvent';
    widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
    widget.Tag=widget.ObjectProperty;

    widget.ColSpan=[2,4];
    widget.RowSpan=[configurationRow,configurationRow];
    MaxBlockId=widget;

    paramsgroupRow=0;


    paramsgroupRow=paramsgroupRow+1;
    nvramcontainer.Type='group';
    nvramcontainer.Name=DAStudio.message('autosarstandard:ui:uiNVRAMParamDesc');
    nvramcontainer.Tag=[tagPrefix,'nvramcontainer'];

    nvramcontainer.LayoutGrid=[configurationRow+1,2];

    nvramcontainer.RowStretch=[zeros(1,configurationRow),1];

    nvramcontainer.ColSpan=[1,1];
    nvramcontainer.RowSpan=[paramsgroupRow,paramsgroupRow];
    nvramcontainer.Items={
MaxBlockIdLabel...
    ,MaxBlockId};

    configurationRow=0;


    maintab=[];

    if isDem
        maintab.Name=DAStudio.message('autosarstandard:ui:uiDemTab');
    else
        maintab.Name=DAStudio.message('autosarstandard:ui:uiNvMTab');
    end

    maintab.Tag=[tagPrefix,'maintab'];
    maintab.LayoutGrid=[configurationRow,2];
    if isDem
        maintab.Items={debouncecontainer};
    else
        maintab.Items={nvramcontainer};
    end


    tabcontainer.Type='tab';
    tabcontainer.Tag=[tagPrefix,'tabcontainer'];

    tabcontainer.ColSpan=[1,1];
    tabcontainer.RowSpan=[2,2];

    if isDem
        tabs={
        autosar.ui.bsw.PortConfigTab.getTab(h)...
        ,autosar.ui.bsw.MainTab.getTab(h)...
        ,autosar.ui.bsw.FimTab.getTab(h)...
        };
        if slfeature('FaultAnalyzerBsw')
            tabs{end+1}=autosar.ui.bsw.FaultTab.getTab(h);
        end
    else
        tabs={
        autosar.ui.bsw.PortConfigTab.getTab(h)...
        ,autosar.ui.bsw.MainTab.getTab(h)
        };
        if slfeature('NVRAMInitialValue')
            tabs{end+1}=autosar.ui.bsw.NvMTab.getTab(h);
        end
    end
    tabcontainer.Tabs=tabs;


    widget=[];
    if isDem
        widget.Name=DAStudio.message('autosarstandard:ui:uiDiagServiceCompDesc');
    else
        widget.Name=DAStudio.message('autosarstandard:ui:uiNVRAMServiceCompDesc');
    end
    widget.Type='text';
    widget.WordWrap=true;
    widget.Tag=[tagPrefix,'MaskDescriptionLabel'];
    widget.ColSpan=[1,1];
    widget.RowSpan=[1,1];
    MaskDescriptionLabel=widget;


    descgroup.Type='group';
    descgroup.Name=get_param(bswCompPath,'MaskType');
    descgroup.Tag=[tagPrefix,'DescGroup'];
    descgroup.LayoutGrid=[1,1];

    descgroup.ColSpan=[1,1];
    descgroup.RowSpan=[1,1];
    descgroup.Items={MaskDescriptionLabel};


    panel.Type='panel';
    panel.Tag=[tagPrefix,'DialogPanel'];
    panel.Items={descgroup,tabcontainer};

    panel.LayoutGrid=[3,1];

    panel.RowStretch=[0,0,0];


    dlgStruct.DialogTag=[tagPrefix,'DiagnosticServiceComponent'];
    dlgStruct.Items={panel};
    dlgStruct.LayoutGrid=[1,1];


    dlgStruct.HelpMethod='helpCallback';


    dlgStruct.PreApplyMethod='PreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

end





