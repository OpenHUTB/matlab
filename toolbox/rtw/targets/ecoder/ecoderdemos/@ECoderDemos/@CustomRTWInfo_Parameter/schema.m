function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('ECoderDemos');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Parameter',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('ECoderDemos_CustomStorageClassList_for_Parameter'))
        cscList=processcsc('GetNamesForParameter','ECoderDemos');
        if isempty(cscList)
            DAStudio.error('Simulink:dialog:CSCNotDefinedForPkg','ECoderDemos');
        end
        schema.EnumType('ECoderDemos_CustomStorageClassList_for_Parameter',cscList);
    end


    schema.prop(hThisClass,'CustomStorageClass','ECoderDemos_CustomStorageClassList_for_Parameter');


    hThisProp=schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    hThisProp.AccessFlags.Init='Off';


    createcsclisteners(hThisClass);
