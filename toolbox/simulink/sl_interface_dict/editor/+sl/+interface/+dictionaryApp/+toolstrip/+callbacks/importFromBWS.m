function importFromBWS(cbinfo)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;



    response=questdlg(...
    DAStudio.message('interface_dictionary:common:ImportFromBaseWorkspaceQuestion'),...
    DAStudio.message('interface_dictionary:common:ImportToInterfaceDictPromptTitle'));

    if~response

        return
    end


    dictObj=guiObj.getInterfaceDictObj;
    dictObj.importFromBaseWorkspace();


