function saveAs(saveAsType,cbinfo)






    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    dictObj=guiObj.getInterfaceDictObj;
    currentDictFilePath=dictObj.filepath;


    [newDictName,newDictPath]=uiputfile(...
    {'*.sldd',...
    DAStudio.message('interface_dictionary:common:InterfaceDictionaryFiles');...
    '*.*','All Files (*.*)'},...
    DAStudio.message('interface_dictionary:common:SaveAsCopyInterfaceDictPromptTitle'));
    newDictFilePath=[newDictPath,newDictName];

    if~newDictName

        return;
    end

    if strcmp(newDictFilePath,currentDictFilePath)


        guiObj.saveDictionary();
        return
    end


    copyfile(currentDictFilePath,newDictFilePath);

    if strcmp(saveAsType,'saveAs')

        newDictObj=Simulink.interface.dictionary.open(newDictFilePath);
        newDictObj.save();
        guiObj.closeDictionary();
        sl.interface.dictionaryApp.StudioApp.open(newDictObj.filepath);
    end
end


