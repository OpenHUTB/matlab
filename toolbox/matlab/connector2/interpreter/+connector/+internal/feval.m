function response=feval(functionName,arguments,numberOfOutputs,contenttype)

    if isempty(contenttype)
        results=connector.internal.fevalJSON(functionName,arguments,numberOfOutputs);
        if results.error
            error(results.faultMessage);
        end
        response=results.results;
    else
        response=connector.internal.fevalMatlab(functionName,arguments,numberOfOutputs);
    end
end