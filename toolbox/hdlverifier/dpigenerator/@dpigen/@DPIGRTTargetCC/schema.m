function schema()





    hCreateInPackage=findpackage('dpigen');
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomTargetCC');
    c=schema.class(hCreateInPackage,'DPIGRTTargetCC',hDeriveFromClass);














    p=add_cc_prop(c,'RTWCAPISignals','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(c,'RTWCAPIParams','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(c,'RTWCAPIStates','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(c,'RTWCAPIRootIO','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(c,'ExtMode','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(c,'ExtModeTransport','slint');
    p.FactoryValue=0;

    p=add_cc_prop(c,'ExtModeStaticAlloc','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(c,'ExtModeStaticAllocSize','slint');
    p.FactoryValue=1000000;

    p=add_cc_prop(c,'ExtModeTesting','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(c,'ExtModeMexFile','ustring');
    p.FactoryValue='ext_comm';

    p=add_cc_prop(c,'ExtModeMexArgs','ustring');
    p.FactoryValue='';

    add_cc_prop(c,'ExtModeIntrfLevel','ustring');

    p=add_cc_prop(c,'AdaptorName','string');
    p.FactoryValue='';
    p.setGrandfathered;

    p=add_cc_prop(c,'GenerateASAP2','slbool');
    p.FactoryValue='off';

    if isempty(findtype('CONFIG_TARGET_MULTIINSTANCEERRORCODE_ENUM'))
        schema.EnumType('CONFIG_TARGET_MULTIINSTANCEERRORCODE_ENUM',...
        {'None','Warning','Error'},[1,2,3]);
    end
    p=add_cc_prop(c,'MultiInstanceErrorCode','CONFIG_TARGET_MULTIINSTANCEERRORCODE_ENUM');
    p.FactoryValue='Error';


    add_prop(c,'DPICustomizeSystemVerilogCode','slbool','off');
    add_prop(c,'DPISystemVerilogTemplate','string','svdpi_event.vgt');


    p=add_prop(c,'DPIReportRunTimeError','slbool','off');
    p.GetFunction=@GetDPIReportRunTimeError;

    if isempty(findtype('RunTimeErrorSeverityOptions'))
        schema.EnumType('RunTimeErrorSeverityOptions',...
        {'Info','Warning','Error','Fatal'});
    end
    add_prop(c,'DPIRunTimeErrorSeverity','RunTimeErrorSeverityOptions','Fatal');



    add_prop(c,'DPIScalarizePorts','slbool','off');


    p=add_prop(c,'DPIGenerateTestBench','slbool','off');
    p.GetFunction=@GetDPIGenerateTestBench;

    if isempty(findtype('HDLSimulatorOptions'))
        schema.EnumType('HDLSimulatorOptions',...
        {'Mentor Graphics Questasim','Cadence Xcelium','Synopsys VCS','Vivado Simulator'});
    end
    add_prop(c,'DPITestBenchSimulator','HDLSimulatorOptions','Mentor Graphics Questasim');


    add_prop(c,'DPITestPointAccessFcnInterface','string','None');


    if isempty(findtype('FixedPointDataTypeOptions'))
        schema.EnumType('FixedPointDataTypeOptions',...
        {'CompatibleCType','BitVector','LogicVector'});
    end
    add_prop(c,'DPIFixedPointDataType','FixedPointDataTypeOptions','CompatibleCType');


    if isempty(findtype('PortConnectionOptions'))
        schema.EnumType('PortConnectionOptions',...
        {'Port list','Interface'});
    end
    add_prop(c,'DPIPortConnection','PortConnectionOptions','Port list');


    if isempty(findtype('CompositeDataTypeOptions'))
        schema.EnumType('CompositeDataTypeOptions',...
        {'Flattened','Structure'});
    end
    add_prop(c,'DPICompositeDataType','CompositeDataTypeOptions','Flattened');


    if isempty(findtype('ComponentTemplateTypeOptions'))
        schema.EnumType('ComponentTemplateTypeOptions',...
        {'Sequential','Combinational'});
    end
    p=add_prop(c,'DPIComponentTemplateType','ComponentTemplateTypeOptions','Sequential');
    p.GetFunction=@GetDPIComponentTemplateType;










    add_noncc_prop(c,'propsThatCanDirtyModel','MATLAB array',c.Properties);
    add_noncc_prop(c,'postSetListener','handle','');
















    m=schema.method(c,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};


    m=schema.method(c,'getExtensionUpdate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};



    m=schema.method(c,'getExtensionCompatibleProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'getStringFormat');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(c,'getExtensionDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(c,'dialogExtensionCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','string'};
    s.OutputTypes={};


    m=schema.method(c,'propValueChangeCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};









    m=schema.method(c,'genTag');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};


    m=schema.method(c,'getPropFromTag');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};


    m=schema.method(c,'getPropType');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(c,'pushButtonCallBack');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};

end



function p=add_prop(c,name,type,default,varargin)
    p=Simulink.TargetCCProperty(c,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_PROCESS');

    p.FactoryValue=default;
    if(nargin==5)
        p.Visible=varargin{1};
    end
    if(nargin==6)
        p.AccessFlags.PublicSet=varargin{2};
    end

end













function p=add_noncc_prop(c,name,type,default)
    p=Simulink.TargetCCProperty(c,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');

    p.FactoryValue=default;
    p.Visible='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';
end

function p=add_cc_prop(h,name,type)

    p=Simulink.TargetCCProperty(h,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
end


function val=GetDPIReportRunTimeError(this,val)


    if strcmp(this.DPICustomizeSystemVerilogCode,'on')
        val='off';
    end
end

function val=GetDPIGenerateTestBench(this,val)


    if strcmp(this.DPICustomizeSystemVerilogCode,'on')
        val='off';
    end
end

function val=GetDPIComponentTemplateType(this,val)


    if strcmp(this.DPICustomizeSystemVerilogCode,'on')
        val='Sequential';
    end
end





