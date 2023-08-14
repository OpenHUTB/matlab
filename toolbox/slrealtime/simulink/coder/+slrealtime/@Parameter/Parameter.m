classdef Parameter<Simulink.Parameter



    methods
        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'slrealtime');
            h.CoderInfo.StorageClass='Custom';
            h.CoderInfo.CustomStorageClass='PageSwitching';
        end
    end
end