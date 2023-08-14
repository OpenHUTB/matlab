classdef BlockInfo







    properties


Type


Name


Column


Parameters

    end

    methods
        function obj=BlockInfo(type,name,stage,pairs)
            obj.Type=type;
            obj.Name=name;
            obj.Column=stage;
            obj.Parameters=pairs;
        end
    end
end
