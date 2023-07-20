function outargs=getStepOrOutputMethodOutputNames(obj)


    metaClass=metaclass(obj);
    if metaClass.IsOutputUpdate
        outputMethod='outputImpl';
    else
        outputMethod='stepImpl';
    end
    defaultDefiningClass='matlab.system.SystemImpl';

    numOutputs=getNumOutputs(obj);
    outargs=getMethodArgumentNames(obj,outputMethod,'OutputNames',...
    numOutputs,'varargout',defaultDefiningClass);
end
