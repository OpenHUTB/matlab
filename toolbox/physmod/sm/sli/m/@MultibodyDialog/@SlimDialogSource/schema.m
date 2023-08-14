function schema







    hBasePackage=findpackage('PMDialogs');
    hBaseObj=hBasePackage.findclass('DynDlgSource');
    hCreateInPackage=findpackage('MultibodyDialog');


    cls=schema.class(hCreateInPackage,'SlimDialogSource',hBaseObj);




    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

