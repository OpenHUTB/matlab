function schema







    hBasePackage=findpackage('PMDialogs');
    hBaseObj=hBasePackage.findclass('PmGuiObj');
    hCreateInPackage=findpackage('NetworkEngine');


    hThisClass=schema.class(hCreateInPackage,'PmNeSolverPanel',hBaseObj);