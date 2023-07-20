function editingModeCallback=getEditingModeCallback(hBlock,code)




    expectedCode='{IbhI^*x19kNiE9#_HJY%>ib+,( H^dR*\,,)-/2>>47tbT14''vcT=/[}08Ea';
    if(~strcmp(code,expectedCode))
        configData=RunTimeModule_config;
        pm_error(configData.Error.IncorrectCode_msgid,pmsl_sanitizename(hBlock.Name));
    end
    editingModeCallback='fluids.internal.editingModeCallback(''ParameterEditingModes'',BlockName);';

end