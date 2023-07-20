classdef RungOpTimer<plccore.ladder.RungOpFBCall




    properties(Access=protected)
TimerUnit
    end

    methods
        function obj=RungOpTimer(pou,instance,unit,arglist)
            obj@plccore.ladder.RungOpFBCall(pou,instance,arglist);
            obj.Kind='RungOpTimer';
            obj.TimerUnit=unit;
        end

        function ret=unit(obj)
            ret=obj.TimerUnit;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRungOpTimer(obj,input);
        end

        function ret=toStringHeader(obj)
            ret=sprintf('%s:%s[%s](',obj.instance.toString,obj.pou.name,obj.unit);
        end
    end

end

