function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,'PmEditUnit',hBaseObj);


    p=schema.prop(hThisClass,'Label','mxArray');%#ok
    p=schema.prop(hThisClass,'LabelAttrb','int');%#ok


    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

