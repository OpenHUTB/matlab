function[bool]=isDataArrayModelContainer(val,modelName)


    if nargin>1
        modelName=convertStringsToChars(modelName);
    end

    bool=false;

    if(isDataArray(val)&&...
        ~isFunctionCallSignal(val))


        inportNames=Simulink.iospecification.InportProperty.getInportNames(modelName);
        enableNames=Simulink.iospecification.InportProperty.getEnableNames(modelName);
        triggerNames=Simulink.iospecification.InportProperty.getTriggerNames(modelName);
        portNames=[inportNames',enableNames',triggerNames'];


        numPorts=length(portNames);


        dims=size(val);







        if numPorts==dims(2)-1
            bool=true;
        end


    end