function schema








    hBasePackage=findpackage('PMDialogs');
    hBaseObj=hBasePackage.findclass('PmCheckBox');
    hCreateInPackage=findpackage('NetworkEngine');


    hThisClass=schema.class(hCreateInPackage,'PmNeCheckBox',hBaseObj);