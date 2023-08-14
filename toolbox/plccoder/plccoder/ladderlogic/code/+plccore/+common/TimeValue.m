classdef TimeValue<plccore.common.ConstValue




    properties(Access=protected)
TmUnit
TmValue
    end

    methods
        function obj=TimeValue(value,unit)
            obj@plccore.common.ConstValue(plccore.type.TIMEType,'');
            obj.Kind='TimeValue';
            obj.TmUnit=unit;
            obj.TmValue=plccore.common.ConstValue(plccore.type.DINTType,value);
        end

        function ret=value(obj)
            ret=obj.TmValue.value;
        end

        function ret=unit(obj)
            ret=obj.TmUnit;
        end

        function ret=toString(obj)
            ret=sprintf('%s[%s]',obj.value,obj.unit);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitTimeValue(obj,input);
        end
    end
end


