classdef(Abstract)Data


    properties(Access=protected)
data
    end

    methods
        function obj=Data(dataSource)
            obj.data=dataSource;
        end

        function data=getData(obj)
            data=obj.data;
        end
    end
end

