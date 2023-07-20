function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Signal',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('Simulink_CustomStorageClassList_for_Signal'))
        cscList=processcsc('GetNamesForSignal','Simulink');
        schema.EnumType('Simulink_CustomStorageClassList_for_Signal',cscList);
    end


    schema.prop(hThisClass,'CustomStorageClass','Simulink_CustomStorageClassList_for_Signal');


    schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    createcsclisteners(hThisClass);
