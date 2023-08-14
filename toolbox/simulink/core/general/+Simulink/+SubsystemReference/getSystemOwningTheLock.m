function result=getSystemOwningTheLock(input)












    inputType=get_param(input,'Type');
    validType=(strcmp(inputType,'block_diagram')&&bdIsSubsystem(input))||...
    (strcmp(inputType,'block')&&strcmp(get_param(input,'BlockType'),'SubSystem'));
    if~validType
        error(message('Simulink:SubsystemReference:InvalidBlockOrBDType'));
    end

    handle=get_param(input,'Handle');
    masterName=slInternal('getMasterSRGraph',handle);
    if isempty(masterName)
        result=masterName;
        return;
    end


    if ishandle(input)
        result=get_param(masterName,'Handle');
        return;
    end




    if strcmp(inputType,'block')&&Simulink.ID.isValid(input)
        result=Simulink.ID.getSID(masterName);
    else
        result=masterName;
    end
end
