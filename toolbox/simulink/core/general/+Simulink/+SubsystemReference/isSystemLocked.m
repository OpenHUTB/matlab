function result=isSystemLocked(input)









    inputType=get_param(input,'Type');
    validType=(strcmp(inputType,'block_diagram')&&bdIsSubsystem(input))||...
    (strcmp(inputType,'block')&&strcmp(get_param(input,'BlockType'),'SubSystem'));
    if~validType
        error(message('Simulink:SubsystemReference:InvalidBlockOrBDType'));
    end

    result=slInternal('isSRGraphLockedForEditing',get_param(input,'Handle'));
end
