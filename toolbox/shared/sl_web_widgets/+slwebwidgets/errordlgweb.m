function errordlgweb(fullChannel,webDlgTitleKey,webDlgMsg)








    dlgData.Title=DAStudio.message(webDlgTitleKey);


    dlgData.Msg=webDlgMsg;


    dlgData.dlgID=webDlgTitleKey;

    payLoad.iconClass='errorIcon';
    payLoad.data=dlgData;


    message.publish(fullChannel,payLoad);

end

