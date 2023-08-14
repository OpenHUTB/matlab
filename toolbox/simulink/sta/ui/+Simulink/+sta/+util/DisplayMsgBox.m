function DisplayMsgBox(title,msg,buttons,defButton,cb,appInstanceID)











    arg.Title=title;
    arg.Msg=msg;
    arg.Buttons=buttons;
    arg.Default=defButton;
    arg.CbChannel=cb;
    arg.CbUserData=char(matlab.lang.internal.uuid());
    fullChannel=sprintf('/sta%s%s',appInstanceID,'/displayMsgBox');
    message.publish(fullChannel,arg);

end
