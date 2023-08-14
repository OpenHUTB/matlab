%#codegen






function enumValue=getActivationEnum(activationFunctionType)



    [~,activationNames]=...
    enumeration('coder.internal.layer.utils.ElementwiseFunction');

    enumValue=0;
    if ismember(upper(activationFunctionType),activationNames)
        enumValue=double(coder.internal.layer.utils.ElementwiseFunction(activationFunctionType));
    end

end
