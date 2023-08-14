function dlgstruct=getDialogSchema(hSrc,schemaName)




    dlgstruct=[];











    supportFloat_ToolTip=sprintf(...
    'Support floating point data types in the generated code.');

    supportFloat_Name='floating-point numbers';

    supportComplex_ToolTip=sprintf(...
    'Support complex data types in the generated code.');
    supportComplex_Name='complex numbers';

    supportNonFinite_ToolTip=sprintf(...
    'Support non-finite values (inf, nan, -inf) in the generated code.');
    supportNonFinite_ToolTip_d1=sprintf(...
    ['Support non-finite values (inf, nan, -inf) in the generated code.\n',...
    'This option is forced off when ''Support floating-point numbers'' is off.']);
    supportNonFinite_Name='non-finite numbers';

    supportAbsoluteTime_ToolTip=sprintf(...
    ['Support absolute time in the generated code. Blocks such as the\n',...
    'Discrete Integrator may require absolute time.']);
    supportAbsoluteTime_Name='absolute time';

    supportContinuousTime_ToolTip=sprintf(...
    ['Support continuous time in the generated code. This allows blocks to\n',...
    'be configured with a continuous sample time. This option is forced\n',...
    'off when ''Suppress error status...'' is on']);
    supportContinuousTime_Name='continuous time';

    supportNonInlinedSFcns_ToolTip=sprintf(...
    ['Support S-functions that have not been inlined with a TLC file.\n',...
    'Inlined S-functions generate the most efficient code.']);
    supportNonInlinedSFcns_Name='non-inlined S-functions';

    termFun_ToolTip='Generate a model terminate function.';
    termFun_Name='Terminate function required';

    combineOutputUpdate_Name='Single output/update function';
    combineOutputUpdate_ToolTip=sprintf(...
    'Generate a model''s output and update routines into a single step function.');
    combineOutputUpdate_ToolTip_d1=sprintf(...
    ['Generate a model''s output and update routines into a single step function.\n',...
    'This option is forced on when ''GRT compatible call interface'' is on.']);

    codeReuse_Name='Generate reusable code';
    codeReuse_ToolTip=sprintf(...
    'Generate reusable/reentrant code.');

    codeReuseErr_Name='Reusable code error diagnostic:';
    codeReuseErr_ToolTip=sprintf(...
    ['Specify the error diagnostic behavior for cases when\n'...
    ,'data defined in the model violates the requirements\n'...
    ,'for generation of reusable code.'...
    ]);

    rootIO_Name='Pass root-level I/O as:';
    rootIO_ToolTip=sprintf([...
    'Select how to pass the root-level I/O data into the reusable\n',...
    'function.']);

    generateClassInterface_Name='Generate C++ class interface';
    generateClassInterface_ToolTip=sprintf(...
    'Creates a wrapper class for reusable C-style functions and data');

    suppressErr_Name='Suppress error status in real-time model data structure';
    suppressErr_ToolTip=sprintf(...
    ['Remove the error status field of the real-time model data structure\n',...
    'to preserve memory.']);

    customize_Name='Configure Model Functions';
    customize_ToolTip='Configure the model step and initialize functions.';

    customize_method_Name='Configure Class Interface';
    customize_method_ToolTip='Configure Class Interface.';


    sil_group_Name='Support software-in-the-loop (SIL) testing';

    matFileLogging_Name='MAT-file logging';
    matFileLogging_ToolTip='Generate code to log data to a MATLAB .mat file.';

    dataExchangeInterface_Name='Interface:';
    dataExchangeInterface_Entries={'None','C API','External mode','ASAP2'};
    dataExchangeInterface_ToolTip=sprintf(...
    'Specify the desired data interface to generate along with the code.');

    CAPISignals_Name='Signals in C API';
    CAPISignals_ToolTip=sprintf(...
    'Generate signals structure in C API.');

    CAPIParams_Name='Parameters in C API';
    CAPIParams_ToolTip=sprintf(...
    'Generate parameter tuning structures in C API.');

    grtInterface_Name='GRT compatible call interface';
    grtInterface_ToolTip=sprintf(...
    ['Include a code (wrapper) interface that is compatible with the GRT\n',...
    'target.']);

    matName.Name='MAT-file variable name modifier:';
    matName.Entries={'none','rt_','_rt'};
    matName.ToolTip=sprintf(...
    'Augment the MAT-file variable name.');

    target_Name='Software environment';
    interface_Name='Code interface';
    dataExchange_Name='Data exchange';
    validate_Name='Verification';

    pageName='Interface';





    tag='Tag_ConfigSet_RTW_ERT_';





    widget.Name='Support:';
    widget.Type='text';
    support=widget;
    widget=[];


    ObjectProperty='PurelyIntegerCode';
    widget.Name=supportFloat_Name;
    widget.Type='checkbox';
    widget.Value=double(strcmp(hSrc.PurelyIntegerCode,'off'));
    widget.Enabled=~hSrc.isReadonlyProperty(ObjectProperty);
    widget.ToolTip=supportFloat_ToolTip;
    widget.Tag=[tag,'SupportFloat'];
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.UserData.ObjectProperty=ObjectProperty;
    supportFloat=widget;
    widget=[];


    ObjectProperty='SupportComplex';
    widget.Name=supportComplex_Name;
    widget.Type='checkbox';
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=double(~hSrc.isReadonlyProperty(ObjectProperty));
    widget.ToolTip=supportComplex_ToolTip;
    widget.Tag=[tag,ObjectProperty];
    widget.Mode=1;
    supportComplex=widget;
    widget=[];


    ObjectProperty='SupportNonFinite';
    widget.Name=supportNonFinite_Name;
    widget.Type='checkbox';
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=~hSrc.isReadonlyProperty(ObjectProperty)&&...
    (strcmp(hSrc.PurelyIntegerCode,'off')||strcmp(hSrc.SupportNonFinite,'on'));




    if~widget.Enabled&&~hSrc.isReadonlyProperty(ObjectProperty)
        if strcmp(hSrc.SupportNonFinite,'off')
            widget.ToolTip=supportNonFinite_ToolTip_d1;
        else
            widget.ToolTip=supportNonFinite_ToolTip;
        end
    else
        widget.ToolTip=supportNonFinite_ToolTip;
    end
    widget.Tag=[tag,ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    supportNonFinite=widget;
    widget=[];%#ok


    ObjectProperty='SupportAbsoluteTime';
    widget=[];
    widget.Name=supportAbsoluteTime_Name;
    widget.Type='checkbox';
    widget.ObjectProperty=ObjectProperty;
    widget.ToolTip=supportAbsoluteTime_ToolTip;
    widget.Tag=[tag,ObjectProperty];
    widget.Enabled=double(~hSrc.isReadonlyProperty(ObjectProperty));
    widget.Mode=1;
    widget.DialogRefresh=1;
    supportAbsoluteTime=widget;
    widget=[];


    ObjectProperty='SupportContinuousTime';
    widget.Name=supportContinuousTime_Name;
    widget.Type='checkbox';
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=~hSrc.isReadonlyProperty(ObjectProperty);

    widget.ToolTip=supportContinuousTime_ToolTip;
    widget.Tag=[tag,ObjectProperty];
    widget.Mode=1;
    widget.DialogRefresh=1;
    supportContinuousTime=widget;
    widget=[];


    ObjectProperty='SupportNonInlinedSFcns';
    widget.Name=supportNonInlinedSFcns_Name;
    widget.Type='checkbox';
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=double(~hSrc.isReadonlyProperty(ObjectProperty));
    widget.ToolTip=supportNonInlinedSFcns_ToolTip;
    widget.Tag=[tag,ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    supportNonInlinedSFcns=widget;
    widget=[];

    widget.Name=termFun_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='IncludeMdlTerminateFcn';
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.ToolTip=termFun_ToolTip;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    widget.DialogRefresh=1;
    termFun=widget;
    widget=[];

    widget.Name=combineOutputUpdate_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='CombineOutputUpdateFcns';
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty)&&...
    (strcmp(hSrc.GRTInterface,'off')||strcmp(hSrc.CombineOutputUpdateFcns,'on'));





    if~widget.Enabled&&hSrc.isReadonlyProperty(widget.ObjectProperty)
        widget.ToolTip=combineOutputUpdate_ToolTip_d1;
    else
        widget.ToolTip=combineOutputUpdate_ToolTip;
    end
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    combineOutputUpdate=widget;
    widget=[];

    widget.Name=codeReuse_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='MultiInstanceERTCode';
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.ToolTip=codeReuse_ToolTip;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    widget.DialogRefresh=1;
    codeReuse=widget;
    widget=[];

    widget.Name=codeReuseErr_Name;
    widget.Type='combobox';
    widget.ObjectProperty='MultiInstanceErrorCode';
    type=findtype(get(findprop(hSrc,widget.ObjectProperty),'DataType'));
    widget.Entries=type.Strings';
    widget.Values=type.Values;
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.Visible=double(strcmp(hSrc.MultiInstanceERTCode,'on'));
    widget.ToolTip=codeReuseErr_ToolTip;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    codeReuseErr=widget;
    widget=[];

    widget.Name=rootIO_Name;
    widget.Type='combobox';
    widget.ObjectProperty='RootIOFormat';
    type=findtype(get(findprop(hSrc,widget.ObjectProperty),'DataType'));
    widget.Entries=type.Strings';
    widget.Values=type.Values;
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.Visible=double(strcmp(hSrc.MultiInstanceERTCode,'on'));
    widget.ToolTip=rootIO_ToolTip;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    rootIO=widget;
    widget=[];

    widget.Name=generateClassInterface_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='GenerateClassInterface';
    type=findtype(get(findprop(hSrc,widget.ObjectProperty),'DataType'));%#ok
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.Visible=double(strcmp(hSrc.MultiInstanceERTCode,'on'));
    widget.ToolTip=generateClassInterface_ToolTip;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    widget.DialogRefresh=0;
    generateClassInterface=widget;
    widget=[];

    widget.Name=suppressErr_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='SuppressErrorStatus';
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.ToolTip=suppressErr_ToolTip;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    suppressErr=widget;
    widget=[];

    cs=hSrc.getConfigSet();
    isMdlStepFcnProtoCompliant=get_param(cs,'ModelStepFunctionPrototypeControlCompliant');
    widget.Name=customize_Name;
    widget.Type='pushbutton';
    widget.Visible=double(~isempty(cs)&&...
    (strcmp(isMdlStepFcnProtoCompliant,'on')));

    widget.Enabled=double(~isempty(cs)&&...
    hSrc.isActive&&~hSrc.isObjectLocked&&...
    (strcmp(isMdlStepFcnProtoCompliant,'on')));
    widget.ToolTip=customize_ToolTip;
    widget.Tag=[tag,'GenCustomStepWrapper'];
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    customize=widget;
    widget=[];






    inClassGenMode=false;

    if rtwprivate('isCPPClassGenEnabled',cs)
        cppComp=hSrc.getCPPComponent();


        if~isempty(cppComp)
            inClassGenMode=true;

            widget.Name=customize_method_Name;
            widget.Type='pushbutton';
            widget.ToolTip=customize_method_ToolTip;
            widget.Tag=[tag,'GenClassCustomize'];
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag,''};
            widget.ArgDataTypes={'handle','string','string'};
            widget.Mode=1;
            widget.DialogRefresh=1;
            widget.Enabled=double(hSrc.isActive&&~hSrc.isObjectLocked);
            customize_class=widget;
            widget=[];

            privateMember_Name='Make model states private members';
            privateMember_ToolTip='Generate non-I/O model structures as private data members';
            widget.Name=privateMember_Name;
            widget.Type='checkbox';
            widget.ToolTip=privateMember_ToolTip;
            widget.Tag=[tag,'GeneratePrivateDataMembers'];
            widget.Value=strcmp(get(cppComp,'GeneratePrivateDataMembers'),'on');
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag,''};
            widget.ArgDataTypes={'handle','string','string'};
            widget.Mode=1;
            widget.DialogRefresh=1;
            widget.Enabled=double(hSrc.isActive&&~hSrc.isObjectLocked);
            privateMember=widget;
            widget=[];

            accessMethod_Name='Generate access methods for states';
            accessMethod_ToolTip='Generate get/set access methods for non-I/O model structures';
            widget.Name=accessMethod_Name;
            widget.Type='checkbox';
            widget.ToolTip=accessMethod_ToolTip;
            widget.Tag=[tag,'GenerateAccessMethods'];
            widget.Value=strcmp(get(cppComp,'GenerateAccessMethods'),'on');
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag,''};
            widget.ArgDataTypes={'handle','string','string'};
            widget.Mode=1;
            widget.DialogRefresh=1;
            widget.Enabled=double(hSrc.isActive&&~hSrc.isObjectLocked);
            accessMethod=widget;
            widget=[];

            genDestructor_Name='Generate destructor';
            genDestructor_ToolTip='Generate model class destructor';
            widget.Name=genDestructor_Name;
            widget.Type='checkbox';
            widget.ToolTip=genDestructor_ToolTip;
            widget.Tag=[tag,'GenerateDestructor'];
            widget.Value=strcmp(get(cppComp,'GenerateDestructor'),'on');
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag,''};
            widget.ArgDataTypes={'handle','string','string'};
            widget.Mode=1;
            widget.DialogRefresh=1;
            widget.Enabled=double(hSrc.isActive&&~hSrc.isObjectLocked);
            genDestructor=widget;
            widget=[];

            ioAccessMethod_Name='Generate I/O access methods';
            ioAccessMethod_ToolTip='Generate access methods for root level I/O signals';
            widget.Name=ioAccessMethod_Name;
            widget.Type='checkbox';
            widget.ToolTip=ioAccessMethod_ToolTip;
            widget.Tag=[tag,'GenerateIOAccessMethods'];
            widget.Value=strcmp(get(cppComp,'GenerateIOAccessMethods'),'on');
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag,''};
            widget.ArgDataTypes={'handle','string','string'};
            widget.Mode=1;
            widget.DialogRefresh=1;
            widget.Enabled=double(hSrc.isActive&&~hSrc.isObjectLocked);
            ioAccessMethod=widget;
            widget=[];

            inlineAcessMethod_Name='Inline access methods';
            inlineAcessMethod_ToolTip='Inline the generated access methods';
            widget.Name=inlineAcessMethod_Name;
            widget.Type='checkbox';
            widget.ToolTip=inlineAcessMethod_ToolTip;
            widget.Tag=[tag,'InlineAccessMethods'];
            widget.Value=strcmp(get(cppComp,'InlineAccessMethods'),'on');
            widget.ObjectMethod='dialogCallback';
            widget.MethodArgs={'%dialog',widget.Tag,''};
            widget.ArgDataTypes={'handle','string','string'};
            widget.Mode=1;
            widget.DialogRefresh=1;
            widget.Enabled=double(hSrc.isActive&&~hSrc.isObjectLocked);
            inlineAccessMethod=widget;
            widget=[];

        end
    end




    widget.Name=matFileLogging_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='MatFileLogging';
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ToolTip=matFileLogging_ToolTip;
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    matFileLogging=widget;
    widget=[];


    widget.Tag=[tag,'DataExchangeInterface'];
    widget.Name=dataExchangeInterface_Name;
    widget.Type='combobox';
    if strcmp(get(hSrc,'RTWCAPISignals'),'on')||...
        strcmp(get(hSrc,'RTWCAPIParams'),'on')
        widget.Value=1;
        widget.Enabled=((strcmp(get(hSrc,'RTWCAPISignals'),'off')||...
        ~hSrc.isReadonlyProperty('RTWCAPISignals'))&&...
        (strcmp(get(hSrc,'RTWCAPIParams'),'off')||...
        ~hSrc.isReadonlyProperty('RTWCAPIParams')));
    elseif strcmp(get(hSrc,'ExtMode'),'on')
        widget.Value=2;
        widget.Enabled=~hSrc.isReadonlyProperty('ExtMode');
    elseif strcmp(get(hSrc,'GenerateASAP2'),'on')
        widget.Value=3;
        widget.Enabled=~hSrc.isReadonlyProperty('GenerateASAP2');
    else
        widget.Value=0;
        widget.Enabled=~hSrc.isObjectLocked;
    end
    widget.ObjectMethod='dialogCallback';
    widget.Source=hSrc;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Entries=dataExchangeInterface_Entries;
    widget.Values=[0,1,2,3];
    widget.ToolTip=dataExchangeInterface_ToolTip;
    widget.UserData.ObjectProperty={'ExtMode','GenerateASAP2'};
    dataExchangeInterface=widget;
    widget=[];


    widget.Name=CAPISignals_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='RTWCAPISignals';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.Source=hSrc;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.ToolTip=CAPISignals_ToolTip;
    widget.Visible=double(strcmp(get(hSrc,'RTWCAPISignals'),'on')|...
    strcmp(get(hSrc,'RTWCAPIParams'),'on'));
    CAPISignals=widget;
    widget=[];


    widget.Name=CAPIParams_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='RTWCAPIParams';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.Source=hSrc;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.ToolTip=CAPIParams_ToolTip;
    widget.Visible=double(strcmp(get(hSrc,'RTWCAPISignals'),'on')|...
    strcmp(get(hSrc,'RTWCAPIParams'),'on'));
    CAPIParams=widget;
    widget=[];%#ok


    widget=[];
    widget.Name=grtInterface_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='GRTInterface';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.ToolTip=grtInterface_ToolTip;
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    grtInterface=widget;


    matName.Type='combobox';
    matName.ObjectProperty='LogVarNameModifier';
    matName.Values=[0,1,2];
    matName.Enabled=double(~hSrc.isReadonlyProperty('LogVarNameModifier'));
    matName.Visible=isequal(hSrc.MatFileLogging,'on');
    matName.Tag=[tag,matName.ObjectProperty];
    matName.Mode=1;





    sfEnv=hSrc.getCommonOptionDialog('panel');

    sfEnv.RowSpan=[1,1];
    sfEnv.ColSpan=[1,4];
    support.RowSpan=[2,2];
    support.ColSpan=[1,1];
    supportFloat.RowSpan=[2,2];
    supportFloat.ColSpan=[2,2];
    supportNonFinite.RowSpan=[2,2];
    supportNonFinite.ColSpan=[3,3];
    supportComplex.RowSpan=[2,2];
    supportComplex.ColSpan=[4,4];
    supportAbsoluteTime.RowSpan=[3,3];
    supportAbsoluteTime.ColSpan=[2,2];
    supportContinuousTime.RowSpan=[3,3];
    supportContinuousTime.ColSpan=[3,3];
    supportNonInlinedSFcns.RowSpan=[3,3];
    supportNonInlinedSFcns.ColSpan=[4,4];


    group.Name=target_Name;
    group.Type='group';
    group.Items={...
    sfEnv,...
    support,...
    supportFloat,supportNonFinite,supportComplex,...
    supportAbsoluteTime,supportContinuousTime,supportNonInlinedSFcns};
    group.LayoutGrid=[4,4];
    group.ColStretch=[0,1,1,1];
    target=group;
    group=[];

    grtInterface.RowSpan=[1,1];
    grtInterface.ColSpan=[1,1];
    combineOutputUpdate.RowSpan=[1,1];
    combineOutputUpdate.ColSpan=[2,2];
    termFun.RowSpan=[1,1];
    termFun.ColSpan=[3,3];
    codeReuse.RowSpan=[2,2];
    codeReuse.ColSpan=[1,1];
    codeReuseErr.RowSpan=[2,2];
    codeReuseErr.ColSpan=[2,3];
    rootIO.RowSpan=[3,3];
    rootIO.ColSpan=[2,3];
    suppressErr.RowSpan=[4,4];
    suppressErr.ColSpan=[1,2];
    generateClassInterface.RowSpan=[3,3];
    generateClassInterface.ColSpan=[1,1];
    customize.RowSpan=[5,5];
    customize.ColSpan=[1,1];


    group.Name=interface_Name;
    group.Type='group';
    if~inClassGenMode
        group.Items=...
        {grtInterface,combineOutputUpdate,termFun,...
        codeReuse,codeReuseErr,...
        rootIO,...
        suppressErr,customize};

        group.LayoutGrid=[5,3];
    else
        privateMember.RowSpan=[1,1];
        privateMember.ColSpan=[1,1];

        accessMethod.RowSpan=[1,1];
        accessMethod.ColSpan=[2,2];

        genDestructor.RowSpan=[1,1];
        genDestructor.ColSpan=[3,3];

        ioAccessMethod.RowSpan=[2,2];
        ioAccessMethod.ColSpan=[1,1];

        inlineAccessMethod.RowSpan=[2,2];
        inlineAccessMethod.ColSpan=[2,2];

        customize_class.RowSpan=[3,3];
        customize_class.ColSpan=[1,1];

        group.Items=...
        {privateMember,accessMethod,genDestructor,...
        ioAccessMethod,inlineAccessMethod,customize_class};


        group.LayoutGrid=[3,3];








    end

    interface=group;
    group=[];

    matFileLogging.RowSpan=[1,1];
    matFileLogging.ColSpan=[1,1];
    matName.RowSpan=[1,1];
    matName.ColSpan=[2,2];


    group.Name=validate_Name;
    group.Type='group';
    group.Items={matFileLogging,matName};
    group.LayoutGrid=[5,3];
    validate=group;
    group=[];

    extModeGroup=getExtModeOptionDialog(hSrc,'panel');
    dataExchangeInterface.RowSpan=[1,1];
    dataExchangeInterface.ColSpan=[1,2];
    extModeGroup.RowSpan=[2,2];
    extModeGroup.ColSpan=[1,2];
    CAPISignals.RowSpan=[2,2];
    CAPISignals.ColSpan=[1,1];
    CAPIParams.RowSpan=[2,2];
    CAPIParams.ColSpan=[2,2];
    group.Name=dataExchange_Name;
    group.Type='group';
    group.Items={dataExchangeInterface,extModeGroup,CAPISignals,...
    CAPIParams};
    group.LayoutGrid=[2,2];
    dataExchange=group;
    group=[];%#ok





    target.RowSpan=[1,1];
    interface.RowSpan=[2,2];
    validate.RowSpan=[3,3];
    dataExchange.RowSpan=[4,4];
    interfaceTab.Name=pageName;
    interfaceTab.Items={target,interface,validate,dataExchange};
    interfaceTab.LayoutGrid=[5,1];
    interfaceTab.RowStretch=[0,0,0,0,1];


    codeStyleTab=getCodeStyleDialog(hSrc,schemaName);


    templateTab=getTemplateDialog(hSrc,schemaName);


    dataPlacementTab=getDataPlacementDialog(hSrc,schemaName);


    internalMemorySectionTab=getInternalMemorySectionDialog(hSrc,schemaName);



    ideLinkTab=getTgtDialogSchema(hSrc,schemaName);


    tabs.Name='tabs';
    tabs.Type='tab';
    if feature('RTWReplacementTypes')

        replacementTab=getReplacementDialog(hSrc,schemaName);

        if~inClassGenMode
            tabs.Tabs={interfaceTab,codeStyleTab,templateTab,...
            dataPlacementTab,replacementTab,internalMemorySectionTab,...
            ideLinkTab};
        else
            tabs.Tabs={interfaceTab,codeStyleTab,replacementTab,...
            ideLinkTab};
        end
    else
        tabs.Tabs={interfaceTab,codeStyleTab,templateTab,...
        dataPlacementTab,internalMemorySectionTab,ideLinkTab};
    end


    if strcmp(schemaName,'tab')
        dlgstruct.nTabs=length(tabs.Tabs);
        dlgstruct.Tabs=tabs.Tabs;
    else
        dlgstruct.DialogTitle='ERT Target';
        dlgstruct.Items={tabs};
    end

