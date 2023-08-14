function schema








    hCreateInPackage=findpackage('PMDialogs');


    hThisClass=schema.class(hCreateInPackage,'DynCreateInstance');




    m=schema.method(hThisClass,'invoke');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'handle'};

