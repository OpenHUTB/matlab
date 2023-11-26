classdef(Abstract)ParameterInfoBase

    properties(Dependent)
Name
Component
Type
Description
LongDescription
AllowedValues
AllowedDisplayValues
IsUI
IsDynamic
    end

    methods(Abstract)
        getName(obj);
        getComponent(obj);
        getType(obj);
        getDescription(obj);
        getLongDescription(obj);
        getAllowedValues(obj);
        getAllowedDisplayValues(obj);
        getIsUI(obj);
        getIsDynamic(obj);
    end

    methods
        function out=get.Name(obj)
            out=obj.getName;
        end
        function out=get.Component(obj)
            out=obj.getComponent;
        end
        function out=get.Type(obj)
            out=obj.getType;
        end
        function out=get.Description(obj)
            out=obj.getDescription;
        end
        function out=get.LongDescription(obj)
            out=obj.getLongDescription;
        end
        function out=get.AllowedValues(obj)
            out=obj.getAllowedValues;
        end
        function out=get.AllowedDisplayValues(obj)
            out=obj.getAllowedDisplayValues;
        end
        function out=get.IsUI(obj)
            out=obj.getIsUI;
        end
        function out=get.IsDynamic(obj)
            out=obj.getIsDynamic;
        end
    end
end

