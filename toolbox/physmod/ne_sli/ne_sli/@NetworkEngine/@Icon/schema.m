function schema






    mlock;


    hBasePackage=findpackage('PmSli');
    hCreateInPackage=findpackage('NetworkEngine');
    hBaseClass=hBasePackage.findclass('Icon');
    hThisClass=schema.class(hCreateInPackage,'Icon',hBaseClass);


end
