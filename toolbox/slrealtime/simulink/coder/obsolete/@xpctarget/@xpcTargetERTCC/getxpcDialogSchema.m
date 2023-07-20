function dlgstruct=getxpcDialogSchema(hSrc,schemaName)


















    tag='Tag_ConfigSet_XPC_';

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:ExeMode'));
    w.Type='combobox';
    w.ObjectProperty='RL32ModeModifier';
    type=findtype(get(findprop(hSrc,w.ObjectProperty),'DataType'));
    w.Entries=type.Strings';
    w.Tag='ExeMode';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    execMode=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:LogSize'));
    w.Type='edit';
    w.ObjectProperty='RL32LogBufSizeModifier';
    w.Tag='LogSize';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    logBufSize=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:LogTime'));
    w.Type='checkbox';
    w.ObjectProperty='RL32LogTETModifier';
    w.Tag='LogTime';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    logTET=w;

    w=[];
    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:ProfSize'));
    w.Type='edit';
    w.ObjectProperty='xPCRL32EventNumber';
    w.Tag='ProfSize';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);
    EventNum=w;


    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:RTIntSrc'));
    w.Type='combobox';
    w.ObjectProperty='RL32IRQSourceModifier';
    type=findtype(get(findprop(hSrc,w.ObjectProperty),'DataType'));
    w.Entries=type.Strings';
    w.Values=type.Values;
    w.Tag='RTIntSrc';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    irqNo=w;

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:IntBoard'));
    w.Type='combobox';
    w.ObjectProperty='xPCIRQSourceBoard';
    type=findtype(get(findprop(hSrc,w.ObjectProperty),'DataType'));
    w.Entries=type.Strings';
    w.Values=type.Values;
    w.Tag='IntBoard';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    board=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:IntSlot'));
    w.Type='edit';
    w.ObjectProperty='xPCIOIRQSlot';
    w.ToolTip=sprintf([...
'Enter the [bus slot] for a PCI card or -1 for autosearch.\n'...
    ,'For an ISA card enter the base address in the form 0x300.\n'...
    ,'ISA cards do not have autosearch capabilities.']);
    w.Tag='IntSlot';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    slot=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:EnableStateflowAnim'));
    w.Type='checkbox';
    w.ObjectProperty='xPCEnableSFAnimation';
    w.Tag='EnableStateflowAnim';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    sfAutmation=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:DBufferParams'));
    w.Type='checkbox';
    w.ObjectProperty='xpcDblBuff';
    w.Tag='DBufferParams';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    dblBuf=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:LoadParamFile'));
    w.Type='checkbox';
    w.ObjectProperty='xPCLoadParamSetFile';
    w.Tag=w.Name;
    w.Enabled=double(~hSrc.isReadonlyProperty(w.ObjectProperty));
    w.Tag=[tag,w.ObjectProperty];
    w.ObjectMethod='dialogCallback';
    w.MethodArgs={'%dialog',w.Tag,''};
    w.ArgDataTypes={'handle','string','string'};
    w.Source=hSrc;
    w.Value=double(isequal(get(hSrc,w.ObjectProperty),'on'));
    w.Mode=1;
    w.DialogRefresh=1;



    loadParamFlag=w;
    w=[];


    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:FileName'));
    w.Type='edit';
    w.ObjectProperty='xPCOnTgtParamSetFileName';
    w.Tag=[tag,w.ObjectProperty];
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    onTgtparamsetfname=w;
    w=[];


    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:GenCANape'));
    w.Type='checkbox';
    w.ObjectProperty='xPCGenerateASAP2';
    w.Tag='GenCANape';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    asap2=w;
    w=[];


    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:AutoDownload'));
    w.Type='checkbox';
    w.ObjectProperty='xPCisDownloadable';
    w.Enabled=double(~hSrc.isReadonlyProperty(w.ObjectProperty));
    w.Tag=[tag,w.ObjectProperty];
    w.ObjectMethod='dialogCallback';
    w.MethodArgs={'%dialog',w.Tag,''};
    w.ArgDataTypes={'handle','string','string'};
    w.Source=hSrc;
    w.Value=double(isequal(get(hSrc,w.ObjectProperty),'on'));
    w.Mode=1;
    w.DialogRefresh=1;

    isxpcdownload=w;
    w=[];



    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:DefaultDownload'));
    w.Type='checkbox';
    w.ObjectProperty='xPCisDefaultEnv';
    w.Enabled=double(~hSrc.isReadonlyProperty(w.ObjectProperty));
    w.Tag=[tag,w.ObjectProperty];
    w.ObjectMethod='dialogCallback';
    w.MethodArgs={'%dialog',w.Tag,''};
    w.ArgDataTypes={'handle','string','string'};
    w.Source=hSrc;
    w.Value=double(isequal(get(hSrc,w.ObjectProperty),'on'));
    w.Mode=1;
    w.DialogRefresh=1;


    isdefEnv=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:TargetName'));
    w.Type='edit';
    w.ObjectProperty='xPCTargetPCEnvName';
    w.Tag=[tag,w.ObjectProperty];
    w.Value=get(hSrc,w.ObjectProperty);

    w.ObjectMethod='dialogCallback';
    w.MethodArgs={'%dialog',w.Tag,''};
    w.ArgDataTypes={'handle','string','string'};
    w.Source=hSrc;
    w.Mode=1;

    tgpcenvName=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:TargetObject'));
    w.Type='edit';
    w.ObjectProperty='RL32ObjectName';
    w.Tag='TargetObject';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    tgName=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:UseDefaultTimeout'));
    w.Type='checkbox';
    w.ObjectProperty='xPCisModelTimeout';
    w.Enabled=double(~hSrc.isReadonlyProperty(w.ObjectProperty));
    w.Tag=[tag,w.ObjectProperty];
    w.ObjectMethod='dialogCallback';
    w.MethodArgs={'%dialog',w.Tag,''};
    w.ArgDataTypes={'handle','string','string'};
    w.Source=hSrc;
    w.Value=double(isequal(get(hSrc,w.ObjectProperty),'on'));
    w.Mode=1;
    w.DialogRefresh=1;


    isModelTimeout=w;
    w=[];

    w.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:ComTimeout'));
    w.Type='edit';
    w.ObjectProperty='xPCModelTimeoutSecs';
    w.Tag='ComTimeout';
    w.Enabled=~hSrc.isReadonlyProperty(w.ObjectProperty);

    ValModelTimeout=w;
    w=[];



    if strcmpi(hSrc.xPCisDownloadable,'off')
        tgName.Visible=0;
        tgName.Enabled=0;

    else
        tgpcenvName.Visible=1;
        isdefEnv.Visible=1;
        tgName.Visible=1;
        if strcmp(hSrc.xPCisDefaultEnv,'off')
            tgpcenvName.Enabled=1;
            tgpcenvName.Visible=1;
        else
            tgpcenvName.Enabled=0;
            tgpcenvName.Visible=0;
        end
    end

    if strcmpi(hSrc.xPCisModelTimeout,'off')
        ValModelTimeout.Visible=1;
    else
        ValModelTimeout.Visible=0;
    end

    if isequal(lower(hSrc.xPCLoadParamSetFile),'off')
        onTgtparamsetfname.Enabled=0;
        onTgtparamsetfname.Visible=0;
    else
        onTgtparamsetfname.Enabled=1;
        onTgtparamsetfname.Visible=1;
    end

    group.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:Options'));
    group.Type='group';
    group.Items={isdefEnv,tgpcenvName,isxpcdownload,tgName,isModelTimeout,ValModelTimeout};

    EnvGrp=group;
    group=[];

    group.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:TunableOptions'));
    group.Type='group';
    group.Items={dblBuf,loadParamFlag,onTgtparamsetfname};

    paramGrp=group;
    group=[];

    group.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:ExeOptions'));
    group.Type='group';
    group.Items={execMode,irqNo,board,slot};

    execGrp=group;
    group=[];

    group.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:LogOptions'));
    group.Type='group';
    group.Items={logTET,logBufSize,EventNum};

    logGrp=group;
    group=[];

    group.Name=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:MiscOptions'));
    group.Type='group';
    group.Items={asap2,sfAutmation};

    miscGrp=group;
    group=[];






    panel.Name='xPCTargetPanel';
    panel.Type='panel';
    panel.Items={EnvGrp,execGrp,logGrp,paramGrp,miscGrp};
    panel.Tag='Tag_ConfigSet_RTW_xPC_Target_options';



    title=getString(message('slrealtime:obsolete:xpcTargetCC:Dialog:TargetOptions'));


    if strcmp(schemaName,'tab')
        dlgstruct.Name=title;
    else
        dlgstruct.DialogTitle=title;
    end
    dlgstruct.Items={panel};
