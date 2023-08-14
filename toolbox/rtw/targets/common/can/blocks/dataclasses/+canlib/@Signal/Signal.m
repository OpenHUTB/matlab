classdef Signal<Simulink.Signal




    methods

        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'canlib');


            h.CoderInfo.StorageClass='Custom';
            h.CoderInfo.CustomStorageClass='Daq_List_Signal_Processing';
        end

        function h=Signal()

        end

    end
end
