classdef SimulinkModelCloner




    methods(Static)
        function modelNameForBackup=backupModel(modelName,displayMessages)
            if nargin<2
                displayMessages=true;
            end
            modelNameForBackup=autosar.mm.util.makeFileNameUnique([modelName,'_backup.slx']);
            if displayMessages
                msg=message('RTW:autosar:savingModel',modelNameForBackup).getString();
                autosar.mm.util.MessageReporter.print(msg);
            end

            slInternal('snapshot_slx',modelName,modelNameForBackup);
        end
    end
end


