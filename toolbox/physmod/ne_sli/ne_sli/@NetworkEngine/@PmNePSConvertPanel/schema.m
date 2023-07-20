function schema







    hBasePackage=findpackage('PMDialogs');
    hBaseObj=hBasePackage.findclass('PmGuiObj');
    hCreateInPackage=findpackage('NetworkEngine');


    hThisClass=schema.class(hCreateInPackage,'PmNePSConvertPanel',hBaseObj);


    m=schema.method(hThisClass,'Apply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

end
