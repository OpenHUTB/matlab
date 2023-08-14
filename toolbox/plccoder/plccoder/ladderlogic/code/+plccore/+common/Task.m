classdef(Abstract)Task<plccore.common.Object




    properties(Access=protected)
Name
Description
Priority
WatchdogTime
TaskKlass
ProgList
    end

    methods
        function obj=Task(name,desc,pri,watchdog_tm,tsk_class)
            obj.Kind='Task';
            obj.Name=name;
            obj.Description=desc;
            obj.Priority=str2num(pri);%#ok<ST2NM>
            obj.WatchdogTime=str2num(watchdog_tm);%#ok<ST2NM>
            obj.TaskKlass=tsk_class;
            obj.ProgList={};
        end

        function ret=name(obj)
            ret=obj.Name;
        end

        function ret=setName(obj,name)
            obj.Name=name;
            ret=[];
        end

        function ret=desc(obj)
            ret=obj.Description;
        end

        function ret=priority(obj)
            ret=obj.Priority;
        end

        function ret=watchdogTime(obj)
            ret=obj.WatchdogTime;
        end

        function ret=taskClass(obj)
            ret=obj.TaskKlass;
        end

        function ret=programList(obj)
            ret=obj.ProgList;
        end

        function appendProgram(obj,prog)
            obj.ProgList{end+1}=prog;
        end

        function ret=toString(obj)
            import plccore.common.TaskClass;
            txt=sprintf('%s: %s (class=%s, pri=%d, wt=%d%s)\n',obj.Kind,obj.Name,...
            TaskClass.taskClassName(obj.taskClass),obj.priority,obj.watchdogTime,obj.toStringCustom);
            if~isempty(obj.Description)
                txt=[txt,sprintf('  Description: %s\n',obj.Description)];
            end
            proglist=obj.programList;
            for i=1:length(proglist)
                prog=proglist{i};
                txt=[txt,sprintf('  %s: %s\n',prog.kind,prog.name)];%#ok<AGROW>
            end
            ret=txt;
        end
    end

    methods(Access=protected)
        function ret=toStringCustom(obj)%#ok<MANU>
            ret='';
        end
    end
end


