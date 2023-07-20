

function schema

    hSuperPackage=findpackage('Simulink');
    hSuperClass=findclass(hSuperPackage,'SLDialogSource');
    hPackage=findpackage('widgetblocksdlgs');
    hThisClass=schema.class(hPackage,'CallbackWebBlock',hSuperClass);

    p=schema.prop(hThisClass,'editingFcn','int');
    p=schema.prop(hThisClass,'emptyPressFcn','bool');


    m=schema.method(hThisClass,'getSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'callbackBlockFcnSelectionChangeCB','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','int'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};


    m=schema.method(hThisClass,'CallbackBlockPropCB_ddg','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','handle','string','string'};
    s.OutputTypes={};