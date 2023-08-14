function schema






    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,'PmDisplayBox',hBaseObj);


    p=schema.prop(hThisClass,'Label','ustring');
    p=schema.prop(hThisClass,'LabelAttrb','int');
    p=schema.prop(hThisClass,'Value','ustring');
