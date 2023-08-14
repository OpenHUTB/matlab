



function schema

    hDeriveFromPackage=findpackage('hmiblockdlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SignalDlg');
    hCreateInPackage=findpackage('aeroblkhmidlg');
    this=schema.class(hCreateInPackage,'ClimbIndicatorBlock',hDeriveFromClass);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'getSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

end
