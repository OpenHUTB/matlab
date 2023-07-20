function schema






    mlock;

    pk=findpackage('fdhdlcoderui');
    c=schema.class(pk,'fdhdltooldlg');
    set(c,'Description','filter HDL coder dialog');

    p=schema.prop(c,'SubComponents','mxArray');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Serialize='off';
    set(p,'Visible','off');

    findclass(findpackage('hdlcoderprops'),'CLI');
    p=schema.prop(c,'CLIProperties','hdlcoderprops.CLI');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'filterObj','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.Serialize='off';
    set(p,'Visible','off');

    p=schema.prop(c,'hdlFilter','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.Serialize='off';
    set(p,'Visible','off');

    p=schema.prop(c,'HDLActiveTab','int');
    set(p,'FactoryValue',0,'Visible','off');

    p=schema.prop(c,'generateMATLABFile','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';
    set(p,'FactoryValue',false,'Visible','off');

    p=schema.prop(c,'GroupSelection','mxArray');
    p.FactoryValue=0;

    if isempty(findtype('FDHDLCArchitectureType')),
        schema.EnumType('FDHDLCArchitectureType',{'Fully parallel','Fully serial','Partly serial','Cascade serial','Distributed arithmetic (DA)'},[1,2,3,4,5]);
    end

    p=schema.prop(c,'hArchitect','handle');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'notHDLableMsg','ustring');
    p.AccessFlags.Serialize='off';
    set(p,'FactoryValue','','Visible','off');




    p=schema.prop(c,'TargetLanguage','HDLTargetLanguageType');
    p.AccessFlags.Serialize='off';
    set(p,'Visible','off');

    p=schema.prop(c,'HDL_Listener','handle.listener');
    p.AccessFlags.Serialize='off';
    set(p,'AccessFlags.PublicSet','On','AccessFlags.PublicGet','On','Visible','off');

    p=schema.prop(c,'hFPGAWorkflowProps','handle');
    p.AccessFlags.Serialize='off';
    set(p,'Visible','off');

    p=schema.prop(c,'TargetLanguage_bk','ustring');
    p.AccessFlags.Serialize='off';
    set(p,'FactoryValue','','Visible','off');

    p=schema.prop(c,'InputComplex_bk','ustring');
    p.AccessFlags.Serialize='off';
    set(p,'FactoryValue','','Visible','off');

    p=schema.prop(c,'AddRatePort_bk','ustring');
    p.AccessFlags.Serialize='off';
    set(p,'FactoryValue','','Visible','off');

    p=schema.prop(c,'ResetType_bk','ustring');
    p.AccessFlags.Serialize='off';
    set(p,'FactoryValue','','Visible','off');

    p=schema.prop(c,'ResetAssertedLevel_bk','ustring');
    p.AccessFlags.Serialize='off';
    set(p,'FactoryValue','','Visible','off');

    schema.event(c,'CloseDialog');




    m=schema.method(c,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'bool','string'};

    m=schema.method(c,'setfilter');
    s=m.Signature;
    s.varargin='off';


    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','string'};

    m=schema.method(c,'setfiltername');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(c,'getparam');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};

    m=schema.method(c,'getsubcomponent');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'handle'};

    m=schema.method(c,'getproductname');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

