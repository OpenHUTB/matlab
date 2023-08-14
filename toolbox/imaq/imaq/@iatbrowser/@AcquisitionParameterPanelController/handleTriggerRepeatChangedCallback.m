function handleTriggerRepeatChangedCallback(~,~,event)









    vidObj=iatbrowser.Browser().currentVideoinputObject;

    javaTriggerRepeat=double(event.JavaEvent);
    mlTriggerRepeat=javaTriggerRepeat-1;

    if mlTriggerRepeat==vidObj.TriggerRepeat
        return
    end

    if isempty(vidObj.UserData)
        data.FramesPerTrigger=1;
        data.TriggerRepeat=0;
        vidObj.UserData=data;
    end

    if~isinf(mlTriggerRepeat)
        data=vidObj.UserData;
        data.TriggerRepeat=mlTriggerRepeat;
        vidObj.UserData=data;
    end

    set(vidObj,'TriggerRepeat',mlTriggerRepeat);
    commandString='%% TriggerRepeat is zero based and is always one\n%% less than the number of triggers.';
    commandString=[commandString,'\nvid.TriggerRepeat = %d;\n\n'];
    ed=iatbrowser.SessionLogEventData(vidObj,commandString,mlTriggerRepeat);
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);


end