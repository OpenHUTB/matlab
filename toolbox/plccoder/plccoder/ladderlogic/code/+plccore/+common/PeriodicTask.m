classdef PeriodicTask<plccore.common.Task


    properties(Access=protected)
Rate
    end

    methods
        function obj=PeriodicTask(name,desc,pri,watchdog_tm,tsk_class,rate)
            obj@plccore.common.Task(name,desc,pri,watchdog_tm,tsk_class);
            obj.Kind='PeriodicTask';
            obj.Rate=str2num(rate);%#ok<ST2NM>
        end

        function ret=rate(obj)
            ret=obj.Rate;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitPeriodicTask(obj,input);
        end

        function ret=toStringCustom(obj)
            ret=sprintf(', rate=%d',obj.rate);
        end
    end
end