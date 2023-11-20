function handleFramesToAcquireChangedCallback(this,obj,event)%#ok<INUSL>

    vidObj=iatbrowser.Browser().currentVideoinputObject;
    framesPerTrigger=double(event.JavaEvent);

    if(vidObj.FramesPerTrigger==framesPerTrigger)
        return
    end

    if~isinf(framesPerTrigger)
        data=vidObj.UserData;
        data.FramesPerTrigger=framesPerTrigger;
        vidObj.UserData=data;
    end

    set(vidObj,'FramesPerTrigger',framesPerTrigger);
    ed=iatbrowser.SessionLogEventData(vidObj,'vid.FramesPerTrigger = %d;\n\n',framesPerTrigger');
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

    if~isinf(get(vidObj,'FramesPerTrigger'))
        set(vidObj,'FramesAcquiredFcnCount',framesPerTrigger);
    end

    send(this,'handleFramesPerTriggerUpdated');

    if((vidObj.TriggerRepeat~=0)&&isinf(framesPerTrigger))
        md=iatbrowser.MessageDialog();
        md.showMessageDialog(...
        iatbrowser.getDesktopFrame(),...
        'FRAMESPERTRIG_INFTRIG_INFO',...
        [],...
        []);
    end

end