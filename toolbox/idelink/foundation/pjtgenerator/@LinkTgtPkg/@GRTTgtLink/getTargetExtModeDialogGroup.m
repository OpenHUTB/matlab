function group=getTargetExtModeDialogGroup(h,schemaName)




    tag='Tag_ConfigSet_Target_';










    extmode.Name='External mode';
    extmode.ToolTip=sprintf(...
    ['Generates communication support code for\n'...
    ,'executing targets in Simulink external mode.']);
    transportLabel.Name='Transport layer:';
    transport.ToolTip=sprintf(...
    ['Selects transport protocols for external mode communications.']);
    static.Name='Static memory allocation';
    static.ToolTip=sprintf(...
    ['Use static memory buffer for external mode\n'...
    ,'instead of allocating dynamic memory (mallocs).']);
    mexArgsLabel.Name='MEX-file arguments:';
    mexArgs.ToolTip='External Mode mex args.';
    memManageGroup.Name='Memory management';
    page_name='External mode options';

    mexFileLabel.Name='MEX-file name:';
    staticSize.Name='Static memory buffer size:';
    staticSize.ToolTip=sprintf(...
    ['Size in bytes of external mode static memory buffer.']);
    interfaceGroup.Name='Host/Target interface';

    cs=h.getConfigSet;
    [transport_list,mexfile_list,interface_list]=extmode_transports(cs);


    extmode.Type='checkbox';
    extmode.ObjectProperty='ExtMode';
    extmode.Mode=1;
    extmode.DialogRefresh=1;
    extmode.Enabled=double(~h.isReadonlyProperty('ExtMode'));
    extmode.Tag=[tag,extmode.ObjectProperty];

    extModeOptionsVisible=strcmp(get(h,'ExtMode'),'on');



    transportLabel.Type='text';


    transport.Type='combobox';
    transport.ObjectProperty='ExtModeTransport';
    transport.Mode=1;
    transport.DialogRefresh=1;
    transport.Entries=transport_list;
    transport.Enabled=double(~h.isReadonlyProperty('ExtModeTransport'));
    transport.Tag=[tag,transport.ObjectProperty];


    static.Type='checkbox';
    static.ObjectProperty='ExtModeStaticAlloc';
    static.Mode=1;
    static.DialogRefresh=1;
    static.Enabled=double(~h.isReadonlyProperty('ExtModeStaticAlloc'));
    static.Tag=[tag,static.ObjectProperty];


    staticSize.Type='edit';
    staticSize.ObjectProperty='ExtModeStaticAllocSize';
    staticSize.Enabled=double(~h.isReadonlyProperty('ExtModeStaticAllocSize'));
    staticSize.Tag=[tag,staticSize.ObjectProperty];
    staticSize.Mode=1;


    mexFileLabel.Type='text';


    mex_file=mexfile_list(h.ExtModeTransport+1);
    h.ExtModeMexFile=mex_file{1};
    mexFile.Name=mex_file{1};
    mexFile.Type='text';


    mexArgsLabel.Type='text';


    mexArgs.Type='edit';
    mexArgs.ObjectProperty='ExtModeMexArgs';
    mexArgs.Mode=1;
    mexArgs.DialogRefresh=1;
    mexArgs.Enabled=double(~h.isReadonlyProperty('ExtModeMexArgs'));
    mexArgs.Tag=[tag,mexArgs.ObjectProperty];


    if strcmp(h.ExtMode,'off')
        transportLabel.Enabled=0;
        transport.Enabled=0;
        static.Enabled=0;
        staticSize.Enabled=0;
        staticSize.Visible=0;
        mexFileLabel.Enabled=0;
        mexFile.Enabled=0;
        mexArgsLabel.Enabled=0;
        mexArgs.Enabled=0;
    else
        if strcmp(h.ExtModeStaticAlloc,'off')
            staticSize.Enabled=0;
            staticSize.Visible=0;
        else
            staticSize.Enabled=1;
            staticSize.Visible=1;
        end
    end


    transportLabel.RowSpan=[1,1];
    transportLabel.ColSpan=[1,1];
    transport.RowSpan=[1,1];
    transport.ColSpan=[2,2];
    mexFileLabel.RowSpan=[1,1];
    mexFileLabel.ColSpan=[3,3];
    mexFile.RowSpan=[1,1];
    mexFile.ColSpan=[4,4];
    mexArgsLabel.RowSpan=[2,2];
    mexArgsLabel.ColSpan=[1,1];
    mexArgs.RowSpan=[2,2];
    mexArgs.ColSpan=[2,4];
    interfaceGroup.Type='group';
    interfaceGroup.LayoutGrid=[2,4];
    interfaceGroup.ColStretch=[0,1,0,1];
    interfaceGroup.Items={transportLabel,transport,mexFileLabel,mexFile,mexArgsLabel,mexArgs};


    memManageGroup.Type='group';
    memManageGroup.Items={static,staticSize};


    group.Name=page_name;
    if strcmp(schemaName,'panel')
        group.Type='panel';
        group.Items={interfaceGroup,memManageGroup};
        group.Visible=extModeOptionsVisible;
    else
        group.Type='group';
        interfaceGroup.Visible=extModeOptionsVisible;
        memManageGroup.Visible=extModeOptionsVisible;
        group.Items={extmode,interfaceGroup,memManageGroup};
    end

