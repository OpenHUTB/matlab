function schema()





    hCreateInPackage=findpackage('dpigen');
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ERTTargetCC');
    c=schema.class(hCreateInPackage,'DPIERTTargetCC',hDeriveFromClass);










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

    if isempty(findtype('HDLSimulatorTypeOptions'))
        schema.EnumType('HDLSimulatorTypeOptions',...
        {'Mentor Graphics Questasim','Cadence Xcelium','Synopsys VCS','Vivado Simulator'});
    end
    add_prop(c,'DPITestBenchSimulator','HDLSimulatorTypeOptions','Mentor Graphics Questasim');


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

function val=GetDPIReportRunTimeError(this,val)


    if strcmp(this.DPICustomizeSystemVerilogCode,'on')
        val='off';
    else

        if~isempty(this.getParent)
            rtwcc=this.getParent;
            if~isempty(rtwcc.getParent)
                cgset=rtwcc.getParent;


                if isa(cgset,'Simulink.ConfigSet')&&strcmp(cgset.get_param('SuppressErrorStatus'),'on')
                    val='off';
                end
            end
        end
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






