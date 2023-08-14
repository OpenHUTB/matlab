function half_info=getHalfPrecisionCompilerSupport(model,genCPP)





    half_info.isNativeHalf=false;


    if~isNativeHalfFeatureEnabled(genCPP)

        return;
    end


    hw_name=get_param(model,'TargetHWDeviceType');


    hw_helper=targetrepository.getHardwareImplementationHelper;


    processor=hw_helper.getDevice(hw_name);


    if isempty(processor)
        return;
    end


    if~isa(processor,'target.internal.Processor')
        return;
    end


    lang_imp=hw_helper.getImplementation(processor);
    compilerHalf=lang_imp.DataTypes.getNativeFloatTypesWithSize(16);

    if~isempty(compilerHalf)&&~isempty(compilerHalf.TypeName)

        half_info.isNativeHalf=true;
        half_info.compilerHalf=compilerHalf;
    end

end

function enabled=isNativeHalfFeatureEnabled(isCPP)

    featureNativeHalf=bitsll(1,9);
    featureNativeHalfCpp=bitsll(1,10);
    featureHalfSL=slfeature('SLHalfPrecisionSupport');

    if(bitand(featureHalfSL,featureNativeHalf)==0)

        enabled=false;
    elseif(isCPP&&(bitand(featureHalfSL,featureNativeHalfCpp)==0))

        enabled=false;
    else
        enabled=true;
    end

end
