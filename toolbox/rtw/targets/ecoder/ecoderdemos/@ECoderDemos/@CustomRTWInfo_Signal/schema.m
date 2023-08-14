function schema()















    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomRTWInfo');
    hCreateInPackage=findpackage('ECoderDemos');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo_Signal',hDeriveFromClass);
    hThisClass.Handle=hDeriveFromClass.Handle;


    if isempty(findtype('ECoderDemos_CustomStorageClassList_for_Signal'))
        cscList=processcsc('GetNamesForSignal','ECoderDemos');
        if isempty(cscList)
            DAStudio.error('Simulink:dialog:CSCNotDefinedForPkg','ECoderDemos');
        end
        schema.EnumType('ECoderDemos_CustomStorageClassList_for_Signal',cscList);
    end


    schema.prop(hThisClass,'CustomStorageClass','ECoderDemos_CustomStorageClassList_for_Signal');


    hThisProp=schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


    hThisProp.AccessFlags.Init='Off';


    createcsclisteners(hThisClass);
