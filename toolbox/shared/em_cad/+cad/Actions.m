classdef(Abstract)Actions<handle&matlab.mixin.Heterogeneous

    properties
ActionInfo
Type
ActionObject
ActionObjectType
Model
    end
    methods
        execute(obj);
        undo(obj);
    end
end
