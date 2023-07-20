function retVal=isHandleObject(value)




    switch Simulink.data.getScalarObjectLevel(value)
    case 1
        classHandle=classhandle(value);
        if strcmp(classHandle.Handle,'on');
            retVal=true;
        else
            retVal=false;
        end
    case 2
        classHandle=metaclass(value);
        if classHandle.HandleCompatible
            retVal=true;
        else
            retVal=false;
        end
    otherwise
        retVal=false;
    end


