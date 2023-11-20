function handleTriggerSourceChangedCallback(this,obj,event)%#ok<INUSL>

    javaPeer=java(this.javaPeer);
    formatNodePanel=javaPeer.getFormatNodePanel();

    vidObj=iatbrowser.Browser().currentVideoinputObject;

    newTriggerSource=char(event.JavaEvent.triggerSource);

    if strcmpi(newTriggerSource,vidObj.TriggerSource)
        return
    end
    hardwareTriggerModes=triggerinfo(vidObj,'hardware');
    triggerConditions={hardwareTriggerModes(strcmp({hardwareTriggerModes.TriggerSource},newTriggerSource)).TriggerCondition};
    if(strcmp(vidObj.TriggerType,'hardware'))
        defaultTriggerCondition=vidObj.TriggerCondition;
    else
        defaultTriggerCondition=triggerConditions{1};
    end
    formatNodePanel.updateHardwareTriggerConditions(triggerConditions,defaultTriggerCondition);
