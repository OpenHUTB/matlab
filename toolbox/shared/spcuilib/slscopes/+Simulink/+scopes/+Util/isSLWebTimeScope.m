function value=isSLWebTimeScope()




    persistent storedValue

    if isempty(storedValue)
        value=logical(matlab.internal.feature('WebScopeSimulinkScope'));
        storedValue=value;
    else
        value=storedValue;
    end
