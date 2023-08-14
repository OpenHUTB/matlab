function flag=isCurrent(variantSystemTag,variantTag)






%#FOR_LEGACY_BLOCK_ONLY


    adapter=FunctionApproximation.internal.approximationblock.TagToBlockAdapter();
    variantSystemHandle=adapter.getSubSystemHandle(variantSystemTag);
    maskObject=Simulink.Mask.get(variantSystemHandle);
    schema=FunctionApproximation.internal.approximationblock.BlockSchema();
    if isempty(maskObject.Initialization)





        maskObject.Initialization=schema.getCallbackForMaskInitialization();

        parameterForFunctionSelection=maskObject.getParameter(schema.FunctionVersionParameterName);
        parameterForFunctionSelection.Callback='';

        set_param(variantSystemHandle,'CopyFcn','');
    end


    flag=strcmp(get_param(variantSystemHandle,schema.CurrentActiveParameterName),variantTag);
end
