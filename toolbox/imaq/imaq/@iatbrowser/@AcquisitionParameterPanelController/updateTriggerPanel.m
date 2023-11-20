function updateTriggerPanel(this)

    javaPeer=java(this.javaPeer);
    formatNodePanel=javaPeer.getFormatNodePanel();

    vidObj=iatbrowser.Browser().currentVideoinputObject;

    iatbrowser.initializeUserData(vidObj);

    data=vidObj.UserData;

    formatNodePanel.updateNumberOfTriggers(vidObj.TriggerRepeat+1,data.TriggerRepeat+1);
    formatNodePanel.setTriggerRepeatForInfFrames(isinf(vidObj.FramesPerTrigger));

    if(strcmp(vidObj.TriggerType,'immediate'))
        formatNodePanel.setImmediateTrigger();
    elseif(strcmp(vidObj.TriggerType,'manual'))
        formatNodePanel.setManualTrigger();
    elseif(strcmp(vidObj.TriggerType,'hardware'))
        formatNodePanel.setHardwareTrigger();
    else
        error(message('imaq:imaqtool:invalidTriggerType'));
    end

    hardwareTriggerModes=triggerinfo(vidObj,'hardware');

    if isempty(hardwareTriggerModes)
        formatNodePanel.setHardwareTriggerFieldsVisible(false);
    else
        formatNodePanel.setHardwareTriggerFieldsVisible(true);

        triggerSources=unique({hardwareTriggerModes.TriggerSource});

        if(strcmp(vidObj.TriggerType,'hardware'))
            defaultTriggerSource=vidObj.TriggerSource;
        else
            defaultTriggerSource=triggerSources{1};
        end

        formatNodePanel.updateHardwareTriggerSources(triggerSources,defaultTriggerSource);
    end

