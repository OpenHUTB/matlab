function saveFramesToMATFile(this,fileName,variableName)%#ok<INUSL>

    eval([variableName,' = this.prevPanel.data;']);
    oldWarningState=warning('error','MATLAB:save:sizeTooBigForMATFile');
    try
        save(fileName,variableName);
    catch err
        if(strcmp(err.identifier,'MATLAB:save:sizeTooBigForMATFile'))
            save(fileName,variableName,'-v7.3','-nocompression');
        else
            warning(oldWarningState);
            rethrow(err);
        end
    end
    warning(oldWarningState);

    ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
    '%s = getdata(vid);\nsave(''%s'', ''%s'');\nclear %s;\n\n',variableName,fileName,variableName,variableName);
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

end
