function schema()

















    schema.package('RTWConfiguration');


    if isempty(findtype('TargetCustomStorageTypes'))
        schema.EnumType('TargetCustomStorageTypes',{
        'Target';});
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists','TargetCustomStorageTypes');
    end

    if isempty(findtype('AllocationHostType'))
        schema.EnumType('AllocationHostType',{
        'char';
        'handle';});
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists','AllocationHostType');
    end

