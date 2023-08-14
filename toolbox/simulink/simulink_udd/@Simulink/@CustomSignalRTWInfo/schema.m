function schema()









    packageName='Simulink';


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage(packageName);


    hThisClass=schema.class(hCreateInPackage,'CustomSignalRTWInfo',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('BuiltInCustomSignalStorageClasses'))
        enumList=processcsc('GetNamesForSignal',packageName);
        schema.EnumType('BuiltInCustomSignalStorageClasses',enumList);
    end


    schema.prop(hThisClass,'CustomStorageClass','BuiltInCustomSignalStorageClasses');


    schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    createcsclisteners(hThisClass);
