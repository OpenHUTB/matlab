function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('mpt');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfoParameter',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('mpt_CustomStorageClassList_for_Parameter'))
        cscList=processcsc('GetNamesForParameter','mpt');
        if isempty(cscList)
            DAStudio.error('Simulink:dialog:CSCNotDefinedForPkg','mpt');
        end
        schema.EnumType('mpt_CustomStorageClassList_for_Parameter',cscList);
    end


    hThisProp=schema.prop(hThisClass,'CustomStorageClass','mpt_CustomStorageClassList_for_Parameter');


    hThisProp.FactoryValue='Global';


    hThisProp=schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    hThisProp.AccessFlags.Init='Off';


    createcsclisteners(hThisClass);


