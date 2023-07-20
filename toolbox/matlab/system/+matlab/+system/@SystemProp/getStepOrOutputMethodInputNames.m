function inputargs=getStepOrOutputMethodInputNames(obj)


    metaClass=metaclass(obj);
    if metaClass.IsOutputUpdate
        inputMethod='updateImpl';
    else
        inputMethod='stepImpl';
    end
    defaultDefiningClass='matlab.system.SystemImpl';

    numInputs=getNumFixedInputs(obj);


    inputargs=getMethodArgumentNames(obj,inputMethod,'InputNames',...
    numInputs+1,'varargin',defaultDefiningClass);
    inputargs=inputargs(2:end);
end
