function handleMemoryLimitChangedCallback(~,~,event)

    memLimit=double(event.JavaEvent);


    memLimit=memLimit*1e6;

    if memLimit==getCurrentMemoryLimit()
        return
    end

    imaqmem(memLimit);

    ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
    'imaqmem(%s);\n\n',num2str(memLimit));
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

    function memoryLimit=getCurrentMemoryLimit


        s=warning('off','imaq:imaqmem:functionToBeRemoved');
        restoreWarning=onCleanup(@()warning(s));
        memoryLimit=imaqmem('FrameMemoryLimit');

    end
end