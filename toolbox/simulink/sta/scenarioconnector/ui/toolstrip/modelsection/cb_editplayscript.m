function[WAS_SUCCESSFUL,errMsg]=cb_editplayscript(scriptFilePath)






    errMsg='';
    WAS_SUCCESSFUL=false;

    if~isfile(scriptFilePath)
        [~,scriptFileOnlyName,ext]=fileparts(scriptFilePath);
        errMsg=DAStudio.message('sl_sta:scenarioconnector:scriptfileexistfalse',[scriptFileOnlyName,ext]);
    else
        edit(scriptFilePath);
        WAS_SUCCESSFUL=true;
    end