function openDictionary(~)





    newDictName=uigetfile(...
    {'*.sldd',...
    DAStudio.message('interface_dictionary:common:InterfaceDictionaryFiles');...
    '*.*','All Files (*.*)'},...
    DAStudio.message('interface_dictionary:common:OpenInterfaceDictPromptTitle'));

    if~newDictName

        return
    end


    newDictObj=Simulink.interface.dictionary.open(newDictName);
    sl.interface.dictionaryApp.StudioApp.open(newDictObj.filepath);


