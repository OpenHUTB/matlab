classdef(AllowedSubclasses={?codergui.internal.ui.ValueTypes,?codergui.internal.ui.ListValueType})ValueType




    properties(Abstract,SetAccess=immutable)
        Id char
        BaseValueType codergui.internal.ui.ValueType
DefaultValue
    end

    properties(SetAccess=immutable)
IsList
    end

    methods
        function this=ValueType(isList)
            this.IsList=isList;
        end
    end

    methods(Abstract)
        value=validateValue(this,value)
        value=fromDecodedJson(this,decoded)
        encodable=toJsonEncodable(this,value)
    end
end
