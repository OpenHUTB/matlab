function updateIsNewDataAvailable(this)





    clientId=this.ClientID;
    hBlock=str2double(clientId);
    modelH=bdroot(hBlock);
    boundSignals=this.getBoundSignals();
    if strcmp(get_param(modelH,'VisualizeSimOutput'),'on')&&~isempty(boundSignals)


        this.IsNewDataAvailable=true;
    else
        this.IsNewDataAvailable=false;
    end