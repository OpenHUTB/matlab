function result=getNearestParentSubsystemReferenceBlock(input)











    if~strcmp(get_param(input,'Type'),'block')
        error(message('Simulink:SubsystemReference:InputMustBeBlock'));
    end

    handle=get_param(input,'Handle');
    result=slInternal('getNearestParentSSRefBlock',handle);
    if isempty(result)
        return;
    end


    if Simulink.ID.isValid(input)
        return;
    elseif ishandle(input)
        result=get_param(result,'Handle');
    else
        result=getfullname(result);
    end
end
