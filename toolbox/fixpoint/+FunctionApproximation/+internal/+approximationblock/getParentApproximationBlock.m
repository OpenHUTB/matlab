function approximationBlock=getParentApproximationBlock(functionToApproximate)






    approximationBlock='';
    topModel=bdroot(functionToApproximate);
    while~strcmp(functionToApproximate,topModel)
        functionToApproximate=get_param(functionToApproximate,'Parent');
        if FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(functionToApproximate)
            approximationBlock=functionToApproximate;
            break;
        end
    end
end
