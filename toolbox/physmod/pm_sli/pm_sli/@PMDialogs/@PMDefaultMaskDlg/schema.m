function schema









    ;
    basePackage=findpackage('Simulink');
    baseClass=findclass(basePackage,'SLDialogSource');
    createPackage=findpackage('PMDialogs');
    cls=schema.class(createPackage,'PMDefaultMaskDlg',baseClass);

    schema.prop(cls,'BlockHandle','double');

    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






