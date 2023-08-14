function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('canlib');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Parameter',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('canlib_CustomStorageClassList_for_Parameter'))
        cscList=processcsc('GetNamesForParameter','canlib');
        if isempty(cscList)
            DAStudio.error('Simulink:dialog:CSCNotDefinedForPkg','canlib');
        end
        schema.EnumType('canlib_CustomStorageClassList_for_Parameter',cscList);
    end


    hThisProp=schema.prop(hThisClass,'CustomStorageClass','canlib_CustomStorageClassList_for_Parameter');
    hThisProp.AccessFlags.Init='off';


    hThisProp=schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    createcsclisteners(hThisClass);
