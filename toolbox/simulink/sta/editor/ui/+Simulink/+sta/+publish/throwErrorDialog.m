function throwErrorDialog(baseMessageChanel,uniqueAppID,errorTitleID,errorMsg)




    msgTopics=Simulink.sta.EditorTopics();


    fullChannel=Simulink.sta.publish.genChannel(baseMessageChanel,uniqueAppID,msgTopics.DIAGNOSTICS_DLG);



    slwebwidgets.errordlgweb(fullChannel,...
    errorTitleID,...
    errorMsg);
