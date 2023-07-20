function result=getActiveInstances(input)













    inputType=get_param(input,'Type');
    validType=(strcmp(inputType,'block_diagram')&&bdIsSubsystem(input))||...
    (strcmp(inputType,'block')&&strcmp(get_param(input,'BlockType'),'SubSystem'));
    if~validType
        error(message('Simulink:SubsystemReference:InvalidBlockOrBDType'));
    end

    handle=get_param(input,'Handle');
    names=slInternal('getActiveSRInstanceNames',handle);
    if isempty(names)
        result=names;
        return;
    end


    if ishandle(input)
        result=get_param(names,'Handle');
        return;
    end




    if strcmp(inputType,'block')&&Simulink.ID.isValid(input)
        result=Simulink.ID.getSID(names);
    else
        result=names;
    end
end
