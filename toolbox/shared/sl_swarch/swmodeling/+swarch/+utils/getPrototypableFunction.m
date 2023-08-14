function functionElem=getPrototypableFunction(functionElem)





    callerFunctionElem=functionElem;

    while~isempty(functionElem.calledFunction)
        functionElem=functionElem.calledFunction;
    end

    if~isempty(functionElem.calledFunctionName)




        error(message('SoftwareArchitecture:Engine:OutOfDateFunction',callerFunctionElem.getName()));
    end
end
