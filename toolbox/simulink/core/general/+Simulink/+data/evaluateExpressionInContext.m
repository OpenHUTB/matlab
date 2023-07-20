function retVal=evaluateExpressionInContext(expr,context)

    retVal=[];
    try
        if isempty(context)
            retVal=evalin('base',string(expr));
        elseif isa(context,'Simulink.ModelWorkspace')
            retVal=slResolve(expr,context.ownerName);
        elseif isa(context,'Simulink.data.dictionary.Section')
            retVal=context.evalin(expr);
        end
    catch E
        return;
    end
end