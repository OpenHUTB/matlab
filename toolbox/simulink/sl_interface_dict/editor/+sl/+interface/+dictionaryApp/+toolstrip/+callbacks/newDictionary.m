function newDictionary(~)






    newDictName=uiputfile(...
    {'*.sldd',...
    DAStudio.message('interface_dictionary:common:InterfaceDictionaryFiles');...
    '*.*','All Files (*.*)'},...
    DAStudio.message('interface_dictionary:common:CreateNewInterfaceDictPromptTitle'));

    if~newDictName

        return;
    end


    newDictObj=Simulink.interface.dictionary.create(newDictName);
    sl.interface.dictionaryApp.StudioApp.open(newDictObj.filepath);
end


