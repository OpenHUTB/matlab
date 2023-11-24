function handleColorspaceChangedCallback(this,obj,event)%#ok<INUSL>

    vidObj=iatbrowser.Browser().currentVideoinputObject;

    colorspace=char(event.JavaEvent.colorspace);
    bayerSensorAlignment=char(event.JavaEvent.bayerSensorAlignment);

    if~strcmpi(vidObj.ReturnedColorSpace,colorspace)
        set(vidObj,'ReturnedColorspace',colorspace);
        ed=iatbrowser.SessionLogEventData(vidObj,'vid.ReturnedColorspace = ''%s'';\n\n',colorspace);
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
    end

    if(~isempty(bayerSensorAlignment)&&~strcmpi(vidObj.BayerSensorAlignment,bayerSensorAlignment))
        set(vidObj,'BayerSensorAlignment',bayerSensorAlignment);
        ed=iatbrowser.SessionLogEventData(vidObj,'vid.BayerSensorAlignment = ''%s'';\n\n',bayerSensorAlignment);
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
    end
