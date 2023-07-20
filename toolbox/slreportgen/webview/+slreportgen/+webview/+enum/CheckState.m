classdef CheckState












    enumeration
        Checked("checked");
        PartiallyChecked("partially checked");
        Unchecked("unchecked");
    end

    properties
        DDGValue;
    end

    methods
        function obj=CheckState(value)
            obj.DDGValue=value;
        end
    end
end
