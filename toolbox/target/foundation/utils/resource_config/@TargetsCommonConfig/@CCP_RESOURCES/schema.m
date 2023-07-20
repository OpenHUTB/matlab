function schema()






    hDeriveFromPackage=findpackage('RTWConfiguration');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ResourceHead');
    hCreateInPackage=findpackage('TargetsCommonConfig');


    hThisClass=schema.class(hCreateInPackage,'CCP_RESOURCES',hDeriveFromClass);


    name='CCP_INSTANCE_FLAG';
    enum={
    'CCP_BLOCK';
    };
    i_reg_type(name,enum);


    hThisProp=schema.prop(hThisClass,'CCP_INSTANCE','handle');
    hThisProp.AccessFlags.Serialize='off';

    function i_reg_type(name,enum)
        if isempty(findtype(name))
            schema.EnumType(name,enum);
        else
            TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists',name);
        end
