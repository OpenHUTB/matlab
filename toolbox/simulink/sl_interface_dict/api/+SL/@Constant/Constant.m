classdef Constant<AUTOSAR.Parameter




    methods
        function setupCoderInfo(obj)
            useLocalCustomStorageClasses(obj,'AUTOSAR');
        end

        function h=Constant(varargin)
            h@AUTOSAR.Parameter(varargin{:});
        end
    end
end
