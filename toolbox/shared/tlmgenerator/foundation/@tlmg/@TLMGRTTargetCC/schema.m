function schema()





    hCreateInPackage=findpackage('tlmg');
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomTargetCC');
    hobj=schema.class(hCreateInPackage,'TLMGRTTargetCC',hDeriveFromClass);

    tlmg.private.UtilTargetCC.schema(hobj);














    p=add_cc_prop(hobj,'RTWCAPISignals','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hobj,'RTWCAPIParams','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hobj,'RTWCAPIStates','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hobj,'RTWCAPIRootIO','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hobj,'ExtMode','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hobj,'ExtModeTransport','slint');
    p.FactoryValue=0;

    p=add_cc_prop(hobj,'ExtModeStaticAlloc','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hobj,'ExtModeStaticAllocSize','slint');
    p.FactoryValue=1000000;

    p=add_cc_prop(hobj,'ExtModeTesting','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hobj,'ExtModeMexFile','ustring');
    p.FactoryValue='ext_comm';

    p=add_cc_prop(hobj,'ExtModeMexArgs','ustring');
    p.FactoryValue='';

    add_cc_prop(hobj,'ExtModeIntrfLevel','ustring');

    p=add_cc_prop(hobj,'AdaptorName','string');
    p.FactoryValue='';
    p.setGrandfathered;

    p=add_cc_prop(hobj,'GenerateASAP2','slbool');
    p.FactoryValue='off';

    if isempty(findtype('CONFIG_TARGET_MULTIINSTANCEERRORCODE_ENUM'))
        schema.EnumType('CONFIG_TARGET_MULTIINSTANCEERRORCODE_ENUM',...
        {'None','Warning','Error'},[1,2,3]);
    end
    p=add_cc_prop(hobj,'MultiInstanceErrorCode','CONFIG_TARGET_MULTIINSTANCEERRORCODE_ENUM');
    p.FactoryValue='Error';












    m=schema.method(hobj,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

end



function p=add_cc_prop(h,name,type)

    p=Simulink.TargetCCProperty(h,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
end

