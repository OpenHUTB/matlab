function modelObject=showFunction(variantSystemTag,variantTag)%#ok<INUSL>





    variantSystemHandle=gcbh;
    modelObject=FunctionApproximation.internal.approximationblock.callback.showFunctionWithHandle(variantSystemHandle,variantTag);
end


