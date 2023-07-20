classdef Rounder<handle

    properties
exponent
    end

    methods
        function obj=Rounder(exponent)
            obj.exponent=exponent;
        end
        function r=roundUp(obj,value)
            delta=uint32(bitsll(1,obj.exponent)-1);
            value=value+delta;
            value=bitsrl(value,obj.exponent);
            value=bitsll(value,obj.exponent);
            r=value;
        end
    end

end