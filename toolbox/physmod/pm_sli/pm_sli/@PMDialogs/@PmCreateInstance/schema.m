function schema









    hCreateInPackage=findpackage('PMDialogs');


    hThisClass=schema.class(hCreateInPackage,'PmCreateInstance');




    m=schema.method(hThisClass,'invoke');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','handle'};
    s.OutputTypes={'handle'};

