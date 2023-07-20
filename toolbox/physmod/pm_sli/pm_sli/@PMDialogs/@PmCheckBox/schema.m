function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmBaseWidget');


    hThisClass=schema.class(hCreateInPackage,'PmCheckBox',hBaseObj);


    p=schema.prop(hThisClass,'Label','ustring');
    p=schema.prop(hThisClass,'LabelAttrb','int');
    p=schema.prop(hThisClass,'Value','bool');
    p=schema.prop(hThisClass,'BuddyItems','PMDialogs.PmGuiObj vector');


    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

