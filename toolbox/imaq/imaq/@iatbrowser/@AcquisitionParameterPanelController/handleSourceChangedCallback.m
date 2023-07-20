function handleSourceChangedCallback(this,~,event)







    vidObj=iatbrowser.Browser().currentVideoinputObject;


    sourceName=char(event.JavaEvent.getSource.getSelectedItem);

    if strcmpi(vidObj.SelectedSourceName,sourceName)
        return
    end


    vidObj.SelectedSourceName=sourceName;
    ed=iatbrowser.SessionLogEventData(vidObj,...
    'vid.SelectedSourceName = ''%s'';\nsrc = getselectedsource(vid);\n\n',sourceName);
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
    this.updateDevicePanel;

end