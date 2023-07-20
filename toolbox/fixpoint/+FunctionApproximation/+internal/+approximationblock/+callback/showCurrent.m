function modelObject=showCurrent(variantSystemTag)%#ok<INUSD>






    variantSystemHandle=gcbh;
    variantChoices=get_param(variantSystemHandle,'Variants');


    for i=1:numel(variantChoices)
        blockPath=variantChoices(i).BlockName;
        if eval(get_param(blockPath,'VariantControl'))
            variantTag=get_param(blockPath,'Tag');
            break;
        end
    end


    modelObject=FunctionApproximation.internal.approximationblock.callback.showFunctionWithHandle(variantSystemHandle,variantTag);
end
