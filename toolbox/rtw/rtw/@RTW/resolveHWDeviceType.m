function result=resolveHWDeviceType(type)












    try
        result=target.internal.resolveHWDeviceType(type);
    catch E
        if strcmp(E.identifier,'targetframework:Utilities:BadHWType')
            E2=MSLException([],'RTW:targetRegistry:badHWType','%s',E.message);
            throw(E2);
        else
            rethrow(E);
        end
    end