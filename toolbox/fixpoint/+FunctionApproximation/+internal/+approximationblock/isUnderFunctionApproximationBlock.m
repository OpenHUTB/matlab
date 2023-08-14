function flag=isUnderFunctionApproximationBlock(functionToApproximate)





    flag=false;
    topModel=bdroot(functionToApproximate);
    while~strcmp(functionToApproximate,topModel)
        functionToApproximate=get_param(functionToApproximate,'Parent');
        if FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(functionToApproximate)
            flag=true;
            break;
        end
    end
end