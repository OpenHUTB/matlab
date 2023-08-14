classdef DataDictionaryCloner<handle




    methods(Static)
        function backedDictionary=backupDictionary(dictionaryFile,displayMessages)
            if nargin<2
                displayMessages=true;
            end



            ddConn=Simulink.data.dictionary.open(dictionaryFile);
            if ddConn.HasUnsavedChanges
                autosar.validation.AutosarUtils.reportErrorWithFixit(...
                'autosarstandard:dictionary:UnableToCopyDirtyDictionary',ddConn.filepath);
            end

            [~,dictionaryName]=fileparts(dictionaryFile);
            backedDictionary=autosar.mm.util.makeFileNameUnique([dictionaryName,'_backup.sldd']);
            if displayMessages
                msg=message('autosarstandard:dictionary:SavingDataDictionary',backedDictionary).getString();
                autosar.mm.util.MessageReporter.print(msg);
            end


            copyfile(ddConn.filepath,backedDictionary);
        end
    end
end



