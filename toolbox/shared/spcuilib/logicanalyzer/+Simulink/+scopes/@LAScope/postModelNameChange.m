function postModelNameChange(this)




    clientID=this.ClientID;
    hModel=str2double(clientID);
    this.WebWindow.Title=getString(message('Spcuilib:logicanalyzer:WebWindowTitle',get_param(hModel,'Name')));

end

