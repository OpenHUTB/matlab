function result=isHWDeviceTypeEq(type1,type2)













    try
        result=target.internal.isHWDeviceTypeEq(type1,type2);
    catch E
        if strcmp(E.identifier,'targetframework:Utilities:BadHWType')
            E2=MSLException([],'RTW:targetRegistry:badHWType','%s',E.message);
            throw(E2);
        else
            rethrow(E);
        end
    end