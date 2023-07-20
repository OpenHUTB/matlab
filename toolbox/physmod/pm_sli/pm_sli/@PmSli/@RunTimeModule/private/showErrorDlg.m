function showErrorDlg(message)







    configData=RunTimeModule_config;

    errordlg(message,pm_message(configData.Label.ErrorDlgTitle_msgid),'modal');
    beep;



