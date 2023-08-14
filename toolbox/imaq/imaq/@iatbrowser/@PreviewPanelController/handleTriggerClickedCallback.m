function handleTriggerClickedCallback(~,~,~)






    trigger(iatbrowser.Browser().currentVideoinputObject);

    ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
    'trigger(vid);\n\n');
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

end