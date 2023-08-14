classdef Signal<AUTOSAR.Signal




    methods

        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'AUTOSAR4');
        end

        function h=Signal(varargin)



            h@AUTOSAR.Signal(varargin{:});
            h.CoderInfo.StorageClass='Custom';
            h.CoderInfo.CustomStorageClass='Global';
        end

    end
end
