function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('canlib');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Signal',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('canlib_CustomStorageClassList_for_Signal'))
        cscList=processcsc('GetNamesForSignal','canlib');
        if isempty(cscList)
            DAStudio.error('Simulink:dialog:CSCNotDefinedForPkg','canlib');
        end
        schema.EnumType('canlib_CustomStorageClassList_for_Signal',cscList);
    end


    hThisProp=schema.prop(hThisClass,'CustomStorageClass','canlib_CustomStorageClassList_for_Signal');
    hThisProp.AccessFlags.Init='off';


    hThisProp=schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    createcsclisteners(hThisClass);
