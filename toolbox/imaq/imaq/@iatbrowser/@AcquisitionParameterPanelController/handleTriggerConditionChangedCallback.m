function handleTriggerConditionChangedCallback(~,~,event)









    vidObj=iatbrowser.Browser().currentVideoinputObject;

    triggerType=char(event.JavaEvent.triggerType);
    triggerCondition=char(event.JavaEvent.triggerCondition);
    triggerSource=char(event.JavaEvent.triggerSource);

    if(strcmpi(triggerType,vidObj.TriggerType)&&...
        (strcmpi(triggerType,'manual')||strcmpi(triggerType,'immediate')||...
        (strcmpi(triggerCondition,vidObj.TriggerCondition)&&strcmpi(triggerSource,vidObj.TriggerSource))))
        return
    end

    hardwareTrigger=imaqgate('privateGetJavaResourceString',...
    'com.mathworks.toolbox.imaq.browser.resources.RES_TABPANE',...
    'TriggeringPanel.fHardLabel');



    if strcmpi(triggerType,hardwareTrigger)
        triggerconfig(vidObj,triggerType,triggerCondition,triggerSource);
        ed=iatbrowser.SessionLogEventData(vidObj,...
        'triggerconfig(vid, ''%s'', ''%s'', ''%s'');\n\n',lower(triggerType),triggerCondition,triggerSource);
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
    else
        triggerconfig(vidObj,triggerType);
        ed=iatbrowser.SessionLogEventData(vidObj,...
        'triggerconfig(vid, ''%s'');\n\n',lower(triggerType));
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
    end
    drawnow;

    browser=iatbrowser.Browser;
    browser.infoPanel.updateFormatNodeInfoDisplay;

end