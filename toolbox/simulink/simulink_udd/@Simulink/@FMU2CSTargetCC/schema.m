function schema()





    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'GRTTargetCC');


    hThisClass=schema.class(hCreateInPackage,'FMU2CSTargetCC',hDeriveFromClass);


    hThisProp=Simulink.TargetCCProperty(hThisClass,'CreateModelAfterGeneratingFMU','slbool');
    hThisProp.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    hThisProp.FactoryValue='on';

    hThisProp=Simulink.TargetCCProperty(hThisClass,'ExportedContent','string');
    hThisProp.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    hThisProp.FactoryValue='project';

    hThisProp=Simulink.TargetCCProperty(hThisClass,'ProjectName','string');
    hThisProp.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    hThisProp.FactoryValue='off';

    hThisProp=Simulink.TargetCCProperty(hThisClass,'SaveDirectory','string');
    hThisProp.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    hThisProp.FactoryValue=pwd;
    hThisProp.AccessFlags.Serialize='off';

    hThisProp=Simulink.TargetCCProperty(hThisClass,'AddIcon','string');
    hThisProp.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    hThisProp.FactoryValue='off';


    hThisProp=Simulink.TargetCCProperty(hThisClass,'SaveSourceCodeToFMU','slbool');
    hThisProp.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    hThisProp.FactoryValue='off';



    hThisProp=Simulink.TargetCCProperty(hThisClass,'AddNativeSimulinkBehavior','slbool');
    hThisProp.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    hThisProp.FactoryValue='off';



    m=schema.method(hThisClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};


