function registerType(name,enum)







    if isempty(findtype(name))

        enum{length(enum)+1}=RTWConfiguration.deactivatedString;
        schema.EnumType(name,enum);
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists',name);
    end;
    return;
