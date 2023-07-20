function warndlgweb(fullChannel,webDlgTitleKey,webDlgMsg)







    dlgData.Title=DAStudio.message(webDlgTitleKey);


    dlgData.Msg=webDlgMsg;


    dlgData.dlgID=webDlgTitleKey;

    payLoad.iconClass='warnIcon';
    payLoad.data=dlgData;


    message.publish(fullChannel,payLoad);

