classdef(Hidden)SessionDir<handle

    methods(Static)
        function setLocation(location)

            if connector.isRunning

                connector.internal.loadServices('','(classifier=session)');

                optionalStruct.stringDataType='ustring';
                connector.internal.configurationSet('connector.sessionDir',location,optionalStruct).get();
            else
                warning('Connector:MissingConfiguration','The configuration service was not loaded.');
            end
        end
    end
end
