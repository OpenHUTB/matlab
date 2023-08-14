function dlg=getGRTDialogSchema(h,schemaName)













    matName.Name='MAT-file variable name modifier:';
    matName.ToolTip=sprintf(...
    ['prefix rt_ to variable name,\n'...
    ,'append _rt to variable name,\n'...
    ,'or no modification.']);
    dataEx_ToolTip=sprintf(...
    ['Generate code and/or data files supporting exchange of signal and parameter\n',...
    'data via one of the following methods:\n',...
    '(1) generation of C API code for interfacing tunable parameters and block\n',...
    'I/O signals;\n',...
    '(2) generation of External Mode support code;\n',...
    '(3) generation of ASAP2 file.\n',...
    'If None is selected, no extra support code is generated.']);
    CAPIParam_Name='Parameters in C API';
    CAPISignal_Name='Signals in C API';
    CAPISignal_ToolTip=sprintf(...
    ['Generate signals structure in C API.']);
    CAPIParam_ToolTip=sprintf(...
    ['Generate parameter tuning structures in C API.']);

    symbol.Name='Verification';
    dataExchange_Name='Data exchange';
    interface_Name='Interface:';
    interface_entries={'None','C-API','External mode','ASAP2'};

    tag='Tag_ConfigSet_Target_';

    extModeGroup=getTargetExtModeDialogGroup(h,schemaName);


    matName.Type='combobox';
    matName.ObjectProperty='LogVarNameModifier';
    matName.Entries={'none','rt_','_rt'};
    matName.Values=[0,1,2];
    matName.Enabled=1;
    matName.Enabled=double(~h.isReadonlyProperty('LogVarNameModifier'));
    matName.Tag=[tag,matName.ObjectProperty];
    matName.Mode=1;

    widget=[];
    widget.Tag=[tag,'DataExchangeInterface'];
    widget.Name=interface_Name;
    widget.Type='combobox';
    if strcmp(get(h,'RTWCAPISignals'),'on')||...
        strcmp(get(h,'RTWCAPIParams'),'on')
        widget.Value=1;
        widget.Enabled=((strcmp(get(h,'RTWCAPISignals'),'off')||...
        ~h.isReadonlyProperty('RTWCAPISignals'))&&...
        (strcmp(get(h,'RTWCAPIParams'),'off')||...
        ~h.isReadonlyProperty('RTWCAPIParams')));
    elseif strcmp(get(h,'ExtMode'),'on')
        widget.Value=2;
        widget.Enabled=~h.isReadonlyProperty('ExtMode');
    elseif strcmp(get(h,'GenerateASAP2'),'on')
        widget.Value=3;
        widget.Enabled=~h.isReadonlyProperty('GenerateASAP2');
    else
        widget.Value=0;
        widget.Enabled=~h.isObjectLocked;
    end
    widget.ObjectMethod='dialogCallback';
    widget.Source=h;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Entries=interface_entries;
    widget.Values=[0,1,2,3];
    widget.ToolTip=dataEx_ToolTip;
    widget.UserData.ObjectProperty={'ExtMode','GenerateASAP2'};
    dataExchangeInterface=widget;
    widget=[];


    ObjectProperty='RTWCAPISignals';
    widget.Name=CAPISignal_Name;
    widget.Type='checkbox';
    widget.Value=double(strcmp(get(h,ObjectProperty),'on'));
    widget.Tag=[tag,ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.Source=h;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=double(~h.isReadonlyProperty(ObjectProperty));
    widget.ToolTip=CAPISignal_ToolTip;
    widget.Visible=double(strcmp(get(h,'RTWCAPISignals'),'on')|...
    strcmp(get(h,'RTWCAPIParams'),'on'));
    widget.UserData.ObjectProperty=ObjectProperty;
    CAPISignals=widget;
    widget=[];


    ObjectProperty='RTWCAPIParams';
    widget.Name=CAPIParam_Name;
    widget.Type='checkbox';
    widget.Value=double(strcmp(get(h,ObjectProperty),'on'));
    widget.Tag=[tag,ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.Source=h;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=double(~h.isReadonlyProperty(ObjectProperty));
    widget.ToolTip=CAPIParam_ToolTip;
    widget.Visible=double(strcmp(get(h,'RTWCAPISignals'),'on')|...
    strcmp(get(h,'RTWCAPIParams'),'on'));
    widget.UserData.ObjectProperty=ObjectProperty;
    CAPIParams=widget;
    widget=[];






    software=h.getTargetSoftwareDialogGroup('group');


    symbol.Type='group';
    symbol.Items={matName};


    extModeGroup=getTargetExtModeDialogGroup(h,'panel');
    group.Name=dataExchange_Name;
    group.Type='group';

    if~isempty(extModeGroup.Items)
        group.Items={dataExchangeInterface,extModeGroup,CAPISignals,...
        CAPIParams};
    else
        group.Items={dataExchangeInterface,CAPISignals,...
        CAPIParams};
    end
    dataExchange=group;
    group=[];

    software.RowSpan=[1,1];
    symbol.RowSpan=[2,2];
    dataExchange.RowSpan=[3,3];
    panel.Name='';
    panel.Type='panel';
    panel.Items={software,symbol,dataExchange};
    panel.LayoutGrid=[4,1];
    panel.RowStretch=[0,0,0,1];

    title='GRT Target';


    if strcmp(schemaName,'tab')
        dlg.Name='Interface';
    else
        dlg.DialogTitle=title;
    end
    dlg.Items={panel};
