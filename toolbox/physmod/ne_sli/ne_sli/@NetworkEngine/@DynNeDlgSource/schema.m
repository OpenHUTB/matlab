function schema








    hBasePackage=findpackage('PMDialogs');
    hBaseObj=hBasePackage.findclass('DynDlgSource');
    hCreateInPackage=findpackage('NetworkEngine');


    cls=schema.class(hCreateInPackage,'DynNeDlgSource',hBaseObj);


    schema.prop(cls,'RequestChooser','bool');
    schema.prop(cls,'ComponentName','ustring');


    m=schema.method(cls,'internalGetSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(cls,'internalGetPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(cls,'updateDialogVisibilities');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};
