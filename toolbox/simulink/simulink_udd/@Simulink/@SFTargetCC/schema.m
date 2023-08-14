function schema()





    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomCC');


    hThisClass=schema.class(hCreateInPackage,'SFTargetCC',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'ApplyToAllLibs','bool');
    hThisProp.FactoryValue=logical(1);

    hThisProp=schema.prop(hThisClass,'Document','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Tag','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'CustomCode','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'CustomInitializer','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'CustomTerminator','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'UserIncludeDirs','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'UserSources','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'UserLibraries','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'CodegenDirectory','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'CodeFlagsInfo','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'Id','int32');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'SelectedCmd','int32');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'TargetOptionsDlg','handle');
    hThisProp.FactoryValue=[];
    hThisProp.AccessFlags.Serialize='off';

    hThisProp=schema.prop(hThisClass,'CoderOptionsDlg','handle');
    hThisProp.FactoryValue=[];
    hThisProp.AccessFlags.Serialize='off';


    m=schema.method(hThisClass,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createChildDlg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};


