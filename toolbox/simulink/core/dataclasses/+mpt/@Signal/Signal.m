classdef Signal<Simulink.Signal




    methods

        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'mpt');


            h.CoderInfo.StorageClass='Custom';
            h.CoderInfo.CustomStorageClass='Global';
        end



        function h=Signal()

        end

    end

end


