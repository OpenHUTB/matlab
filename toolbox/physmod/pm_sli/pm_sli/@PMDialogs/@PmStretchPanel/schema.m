function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,...
    'PmStretchPanel',hBaseObj);


    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};
