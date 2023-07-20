function registerRootType(name,enum)



    if isempty(findtype(name))
        schema.EnumType(name,enum);
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists',name);
    end;
    return;
