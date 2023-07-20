classdef EventTask<plccore.common.Task


    properties(Access=protected)
Rate
Trigger
    end

    methods
        function obj=EventTask(name,desc,pri,watchdog_tm,tsk_class,rate,trigger)
            obj@plccore.common.Task(name,desc,pri,watchdog_tm,tsk_class);
            obj.Kind='EventTask';
            obj.Rate=str2num(rate);%#ok<ST2NM>
            obj.Trigger=trigger;
        end

        function ret=rate(obj)
            ret=obj.Rate;
        end

        function ret=trigger(obj)
            ret=obj.Trigger;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitEventTask(obj,input);
        end

        function ret=toStringCustom(obj)
            ret=sprintf(', rate=%d, trigger=%s',obj.rate,obj.trigger);
        end
    end

end