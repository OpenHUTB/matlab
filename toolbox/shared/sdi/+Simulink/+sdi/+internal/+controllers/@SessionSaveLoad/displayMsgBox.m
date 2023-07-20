function displayMsgBox(appName,title,msg,buttons,defButton,escOption,cb,varargin)
    import Simulink.sdi.internal.controllers.SessionSaveLoad;

    ctrlObj=SessionSaveLoad.getController(appName);
    arg.AppName=appName;
    arg.Title=title;
    arg.Msg=msg;
    arg.Buttons=buttons;
    arg.Default=defButton;
    arg.EscapeOption=escOption;
    arg.CbChannel=Simulink.sdi.internal.controllers.SessionSaveLoad.MsgBoxResponseChannel;
    arg.CbUserData=sdi.Repository.generateUUID();
    ctrlObj.MsgBoxResponseCb.insert(arg.CbUserData,cb);
    [clientID,varargin]=SessionSaveLoad.parseProperty('0','clientID',varargin{:});
    arg.ClientID=num2str(clientID);
    message.publish('/sdi2/displayMsgBox',arg);
end
