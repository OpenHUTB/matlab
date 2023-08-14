function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmBaseWidget');


    hThisClass=schema.class(hCreateInPackage,'PmEditBox',hBaseObj);


    p=schema.prop(hThisClass,'Label','mxArray');
    p=schema.prop(hThisClass,'LabelAttrb','int');
    p=schema.prop(hThisClass,'Value','ustring');


    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

