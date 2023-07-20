function[isInputFilterEnabled,onlyOneInportBlk]=getSimrfConfigBlkSettings(blkH)

















    try
        configBlk=get_param(get_param(get_param(blkH,'Parent'),...
        'Parent'),'Parent');
        enableInterpFilter=get_param(configBlk,'EnableInterpFilter');
        isInputFilterEnabled=strcmpi(enableInterpFilter,'on');
        if isInputFilterEnabled
            oneInportBlk=get_param(configBlk,'HiddenFIRfilterControllerParam');
            onlyOneInportBlk=strcmpi(oneInportBlk,'on');
        else
            onlyOneInportBlk=false;
        end

    catch
        isInputFilterEnabled=false;
        onlyOneInportBlk=false;
    end
end
