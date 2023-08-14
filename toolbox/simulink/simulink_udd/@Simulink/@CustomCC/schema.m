function schema()






mlock


    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ConfigMComponent');


    hThisClass=schema.class(hCreateInPackage,'CustomCC',hDeriveFromClass);




    m=schema.method(hThisClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'okToAttach');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'okToDetach');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isVisible');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isEditableProperty');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string'};
    m.signature.outputTypes={'bool'};

    m=schema.method(hThisClass,'buildDataModel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'loadComponentDataModel');

    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};



