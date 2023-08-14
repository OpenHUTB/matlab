classdef TypeInfo<handle

    properties

        Name(1,1)string;

        Class(1,1)string;
        IsSpecialType(1,1)logical=true;
    end

    methods



















        function ret=IsSpecialTypeClass(obj)

            switch obj.Class
            case "TypedefType"
                ret=true;
            case "StructType"
                ret=true;
            case "EnumType"
                ret=true;
            otherwise
                ret=false;
            end

        end

        function computeSpecialType(obj)
            obj.IsSpecialType=obj.IsSpecialTypeClass();
        end

    end

end