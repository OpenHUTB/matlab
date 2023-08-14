function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmBaseWidget');


    hThisClass=schema.class(hCreateInPackage,'PmLabelSpinner',hBaseObj);


    p=schema.prop(hThisClass,'Label','ustring');
    p.FactoryValue='';
    p=schema.prop(hThisClass,'Value','int');
    p.FactoryValue=1;
    p=schema.prop(hThisClass,'MinValue','int');
    p.FactoryValue=0;
    p=schema.prop(hThisClass,'MaxValue','int');
    p.FactoryValue=99;



