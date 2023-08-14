function schema






    mlock;


    hBasePackage=findpackage('PmSli');
    hCreateInPackage=findpackage('simmechanics');
    hBaseClass=hBasePackage.findclass('Icon');
    hThisClass=schema.class(hCreateInPackage,'Icon',hBaseClass);


end
