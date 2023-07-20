classdef(Hidden)OptionalParameters<matlab.mixin.Copyable





    properties
        Name char
        Description char
        IsSelected(1,1)logical
SelectedValue
DefaultValue
Type
    end

    methods(Access=protected)
        function cp=copyElement(obj)
            cp=copyElement@matlab.mixin.Copyable(obj);
            cp.SelectedValue=[];
            cp.IsSelected=false;
        end
    end

    methods
        function obj=OptionalParameters(name,desc,type,defaultVal)
            if nargin>0
                obj.Name=name;
                obj.Description=desc;
                obj.Type=type;
                obj.DefaultValue=defaultVal;
            end
        end


        function deserializeOptionalParameters(obj,optionsStruct)
            obj.Name=optionsStruct.Name;
            obj.Description=optionsStruct.Description;
            obj.IsSelected=optionsStruct.IsSelected;
            obj.SelectedValue=optionsStruct.SelectedValue;
            obj.DefaultValue=optionsStruct.DefaultValue;
            obj.Type=optionsStruct.Type;
        end
    end
end