function importFromMAT(cbinfo)






    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;

    fileName=uigetfile(...
    {'*.mat',...
    DAStudio.message('interface_dictionary:common:MATFiles');...
    '*.*','All Files (*.*)'},...
    DAStudio.message('interface_dictionary:common:ImportToInterfaceDictPromptTitle'));

    if~fileName

        return
    end

    dictObj=guiObj.getInterfaceDictObj;
    dictObj.importFromFile(fileName);


