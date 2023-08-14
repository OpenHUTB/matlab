classdef Setup<handle




    properties(SetObservable=true)
        ConfigurationData;
    end

    methods
        function[obj,loadedModels]=Setup(modelName)
            loadedModels={};
            obj.ConfigurationData.model='';

            if isempty(modelName)
                obj.ConfigurationData=Simulink.CloneDetection.internal.ClonesData();
            else
                sysHandle=get_param(modelName,'handle');
                obj.ConfigurationData.model=modelName;

                obj.ConfigurationData=Simulink.CloneDetection.internal.ClonesData(modelName);

                set_param(modelName,'CloneDetectionUIObj',obj.ConfigurationData);
            end
        end
    end
end
