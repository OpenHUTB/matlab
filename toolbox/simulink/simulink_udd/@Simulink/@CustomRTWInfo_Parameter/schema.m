function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Parameter',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('Simulink_CustomStorageClassList_for_Parameter'))
        cscList=processcsc('GetNamesForParameter','Simulink');
        schema.EnumType('Simulink_CustomStorageClassList_for_Parameter',cscList);
    end


    schema.prop(hThisClass,'CustomStorageClass','Simulink_CustomStorageClassList_for_Parameter');


    schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    createcsclisteners(hThisClass);
