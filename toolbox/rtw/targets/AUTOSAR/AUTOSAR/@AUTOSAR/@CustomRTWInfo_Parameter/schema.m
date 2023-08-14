function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('AUTOSAR');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Parameter',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('AUTOSAR_CustomStorageClassList_for_Parameter'))
        cscList=processcsc('GetNamesForParameter','AUTOSAR');
        if isempty(cscList)
            DAStudio.error('Simulink:dialog:CSCNotDefinedForPkg','AUTOSAR');
        end
        schema.EnumType('AUTOSAR_CustomStorageClassList_for_Parameter',cscList);
    end


    hThisProp=schema.prop(hThisClass,'CustomStorageClass','AUTOSAR_CustomStorageClassList_for_Parameter');
    hThisProp.AccessFlags.Init='off';


    schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    createcsclisteners(hThisClass);
