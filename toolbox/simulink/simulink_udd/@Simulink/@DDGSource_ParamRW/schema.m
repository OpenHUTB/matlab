function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_ParamRW',hDeriveFromClass);


    p=schema.prop(hThisClass,'paramsMap','mxArray');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'treeID','int');
    p.FactoryValue=0;








    p=schema.prop(hThisClass,'SelectedParamOwner','string');
    p.FactoryValue='';


    p=schema.prop(hThisClass,'SelectedParamName','string');
    p.FactoryValue='';


    p=schema.prop(hThisClass,'TreeSelectedItem','string');
    p.FactoryValue='';


    p=schema.prop(hThisClass,'WorkspaceVariableName','string');
    p.FactoryValue='';

    p=schema.prop(hThisClass,'TreeModel','MATLAB array');
    p.FactoryValue={};


    p=schema.prop(hThisClass,'TreeExpandItems','MATLAB array');
    p.FactoryValue={};


    p=schema.prop(hThisClass,'BusTreeSelectedElement','string');
    p.FactoryValue='';


    p=schema.prop(hThisClass,'BusTreeExpandElements','MATLAB array');
    p.FactoryValue={};


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'ParamAccessor_ddg');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'ParamAccessor_ddg_cb');
    s=m.Signature;
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'PreApplyCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'getExpandTreeItems');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string','double'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'isParamBusOrStructType');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={'mxArray'};
