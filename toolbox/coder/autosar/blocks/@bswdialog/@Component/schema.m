function schema






    parentPkg=findpackage('Simulink');
    parent=findclass(parentPkg,'SLDialogSource');
    package=findpackage('bswdialog');
    hThisClass=schema.class(package,'Component',parent);

    p=schema.prop(hThisClass,'UserData','mxArray');
    p.FactoryValue=[];


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'PreApplyCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'helpCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


