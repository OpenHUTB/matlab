classdef ContinuousTask<plccore.common.Task


    methods
        function obj=ContinuousTask(name,desc,pri,watchdog_tm,tsk_class)
            obj@plccore.common.Task(name,desc,pri,watchdog_tm,tsk_class);
            obj.Kind='ContinuousTask';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitContinuousTask(obj,input);
        end
    end

end