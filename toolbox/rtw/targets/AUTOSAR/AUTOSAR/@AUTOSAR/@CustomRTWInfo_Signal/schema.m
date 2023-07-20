function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('AUTOSAR');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Signal',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('AUTOSAR_CustomStorageClassList_for_Signal'))
        cscList=processcsc('GetNamesForSignal','AUTOSAR');
        if isempty(cscList)
            DAStudio.error('Simulink:dialog:CSCNotDefinedForPkg','AUTOSAR');
        end
        schema.EnumType('AUTOSAR_CustomStorageClassList_for_Signal',cscList);
    end


    hThisProp=schema.prop(hThisClass,'CustomStorageClass','AUTOSAR_CustomStorageClassList_for_Signal');
    hThisProp.AccessFlags.Init='off';


    schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    createcsclisteners(hThisClass);
