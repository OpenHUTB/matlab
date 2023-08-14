classdef DictionaryUtils




    methods(Static,Access=public)
        function timerServiceName=getTimerServiceNameFromUUID(modelName,timerServiceUUID)
            if isempty(timerServiceUUID)
                timerServiceName=DAStudio.message('coderdictionary:mapping:PlatformDefault');
            else
                mdlH=get_param(modelName,'Handle');
                coderData=coderdictionary.data.SlCoderDataClient.getElementByUUIDOfCoderDataType(...
                mdlH,'TimerService',timerServiceUUID);
                timerServiceName=coderData.getProperty('Name');
            end
        end
    end
end
