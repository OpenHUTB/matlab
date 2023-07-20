function schema







    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmColorPicker');


    hThisClass=schema.class(hCreateInPackage,'DynColorPicker',hBaseObj);


    m=schema.method(hThisClass,'OnColorButton');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','handle','handle'};
    s.OutputTypes={};