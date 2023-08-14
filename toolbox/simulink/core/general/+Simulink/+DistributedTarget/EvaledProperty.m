classdef EvaledProperty<handle
    properties
        Name;
        Value;
    end
    methods
        function h=EvaledProperty(name,value)
            h.Name=name;
            h.Value=value;
        end
    end
end
