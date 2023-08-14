function schema()

















    schema.package('cancommon');


    if isempty(findtype('hardwareTypes'))
        schema.EnumType('hardwareTypes',{
        'Virtual 1';
        'Virtual 2';
        'CanAc2Pci 1';
        'CanAc2Pci 2';
        'CanAc2 1';
        'CanAc2 2';
        'CanCardX 1';
        'CanCardX 2';
        'CanPari';
        'CanCardXL 1';
        'CanCardXL 2';});
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists','hardwareTypes');
    end

    if isempty(findtype('dnloadType'))
        schema.EnumType('dnloadType',{
        'RAM application code';
        'Flash application code';});
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists','dnloadType');
    end

    if isempty(findtype('connectiontypes'))
        schema.EnumType('connectiontypes',{
        'CAN';
        'Serial';});
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists','connectiontypes');
    end

    if isempty(findtype('commports'))
        schema.EnumType('commports',{
        'COM1';
        'COM2';
        'COM3';
        'COM4';
        'COM5';
        'COM6';
        'COM7';
        'COM8';});
    else
        TargetCommon.ProductInfo.warning('common','CommonTypeAlreadyExists','commports');
    end
