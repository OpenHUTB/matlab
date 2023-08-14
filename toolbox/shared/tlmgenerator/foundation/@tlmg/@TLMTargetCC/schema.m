function schema()





    hCreateInPackage=findpackage('tlmg');
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ERTTargetCC');
    hobj=schema.class(hCreateInPackage,'TLMTargetCC',hDeriveFromClass);

    tlmg.private.UtilTargetCC.schema(hobj);

end


