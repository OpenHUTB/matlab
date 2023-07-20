function[out,dscr]=InstructionSetExtensions_entries(cs,~,~)




    dscr='InstructionSets enum option is dynamic generated.';

    isAvailable=true;%#ok<NASGU>
    unAvailableString='';

    if isa(cs,'Simulink.ConfigSet')
        config=cs;
    else
        config=cs.getConfigSet;
    end

    if isempty(config)
        isAvailable=false;
        availableInstructionSetsArray={unAvailableString};
    else
        isERT=strcmp(get_param(config,'IsERTTarget'),'on');
        hw=config.getComponent('Hardware Implementation');
        deviceType=configset.internal.util.getTargetOrProdHardwareDevice(hw);
        [isAvailable,availableInstructionSetsArray]=RTW.getAvailableInstructionSets(deviceType,isERT);
    end

    disps=availableInstructionSetsArray;
    strs=availableInstructionSetsArray;



    currentValue=get_param(cs,'InstructionSetExtensions');
    if~isempty(currentValue)
        currentFirst=currentValue{1};
        if~ismember(currentFirst,strs)&&~strcmp(currentFirst,'None')
            curr_str=currentFirst;
            curr_disp=currentFirst;
            disps=[{curr_str};disps];
            strs=[{curr_disp};strs];
        end
    end


    if isAvailable
        none_str='None';
        none_disp=message('Coder:configSet:InstructionSets_None').getString;
        disps=[{none_disp};disps];
        strs=[{none_str};strs];
    end

    disps=unique(disps,'stable');
    strs=unique(strs,'stable');

    out=struct('str',strs,'disp',disps);
