classdef LookupTable<Simulink.LookupTable



    methods
        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'slrealtime');
            h.CoderInfo.StorageClass='Custom';
            h.CoderInfo.CustomStorageClass='PageSwitching';
        end
    end
end