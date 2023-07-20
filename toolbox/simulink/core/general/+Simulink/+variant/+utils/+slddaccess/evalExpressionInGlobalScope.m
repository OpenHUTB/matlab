function varargout=evalExpressionInGlobalScope(modelName,expression)




    numOpArgs=max(2,nargout);
    exep=[];
    try



        [varargout{1:(numOpArgs-1)}]=evalinGlobalScope(modelName,expression);
    catch exep
        [varargout{1:(numOpArgs-1)}]=[];
    end
    varargout{numOpArgs}=exep;
end