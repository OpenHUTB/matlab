classdef Parameter<AUTOSAR.Parameter




    methods

        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'AUTOSAR4');
        end

        function h=Parameter(varargin)



            h@AUTOSAR.Parameter(varargin{:});
            h.CoderInfo.StorageClass='Custom';
            h.CoderInfo.CustomStorageClass='Global';
        end

    end
end
