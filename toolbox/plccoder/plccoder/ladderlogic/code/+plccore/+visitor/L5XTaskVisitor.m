classdef L5XTaskVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=L5XTaskVisitor
            obj.Kind='L5XTaskVisitor';
        end

        function ret=visitTask(obj,host,input)%#ok<INUSD,INUSL>
            import plccore.common.TaskClass;
            ret=struct;
            ret.name_list={'Name','Priority','Watchdog','Class'};
            ret.value_list={host.name,num2str(host.priority),...
            num2str(host.watchdogTime),TaskClass.taskClassName(host.taskClass)};
        end

        function ret=visitContinuousTask(obj,host,input)
            ret=obj.visitTask(host,input);
            ret.name_list{end+1}='Type';
            ret.value_list{end+1}='CONTINUOUS';
        end

        function ret=visitPeriodicTask(obj,host,input)
            ret=obj.visitTask(host,input);
            ret.name_list{end+1}='Type';
            ret.value_list{end+1}='PERIODIC';
            ret.name_list{end+1}='Rate';
            ret.value_list{end+1}=num2str(host.rate);
        end

        function ret=visitEventTask(obj,host,input)
            ret=obj.visitTask(host,input);
            ret.name_list{end+1}='Type';
            ret.value_list{end+1}='EVENT';
            ret.name_list{end+1}='Rate';
            ret.value_list{end+1}=num2str(host.rate);
        end
    end
end

