function hClass=findClass(hPackage,className)




    assert(isscalar(hPackage));
    assert(strcmp(class(hPackage),'meta.package'));%#ok
    hClass=meta.class.fromName([hPackage.Name,'.',className]);


