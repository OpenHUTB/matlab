classdef Configuration<plccore.common.Object




    properties(Access=protected)
Name
GlobalScope
AliasVarsMap
TaskList
    end

    methods
        function obj=Configuration(name)
            obj.Kind='Configuration';
            obj.Name=name;
            obj.GlobalScope=plccore.common.GlobalScope;
            obj.AliasVarsMap=containers.Map;
            obj.TaskList={};
        end

        function ret=name(obj)
            ret=obj.Name;
        end

        function ret=setName(obj,name)
            obj.Name=name;
            ret=obj.Name;
        end

        function ret=toString(obj)
            txt=sprintf('%s %s\n',obj.kind,obj.Name);
            txt=sprintf('%s%s',txt,obj.GlobalScope.toString);
            tasklist=obj.taskList;
            for i=1:length(tasklist)
                task=tasklist{i};
                txt=sprintf('%s->%s',txt,task.toString);
            end
            ret=txt;
        end

        function ret=globalScope(obj)
            ret=obj.GlobalScope;
        end

        function ret=taskList(obj)
            ret=obj.TaskList;
        end

        function fb=createFunctionBlock(obj,name)
            fb=obj.globalScope.createFunctionBlock(name);
        end

        function func=createFunction(obj,name,type)
            func=obj.globalScope.createFunction(name,type);
        end

        function prog=createProgram(obj,name)
            prog=obj.globalScope.createProgram(name);
        end

        function var=createVar(obj,name,type)
            var=obj.globalScope.createVar(name,type);
        end

        function typ=createNamedType(obj,name,type,desc)
            if nargin>3
                typ=obj.globalScope.createNamedType(name,type,desc);
            else
                typ=obj.globalScope.createNamedType(name,type);
            end
        end

        function out=getAliasVarsMap(obj)
            out=obj.AliasVarsMap;
        end

        function appendToAliasVarsMap(obj,aliasVarObj)
            obj.AliasVarsMap(aliasVarObj.name)=aliasVarObj.alias;
        end

        function task=createContinuousTask(obj,name,desc,pri,watchdog_tm,tsk_class)
            task=plccore.common.ContinuousTask(name,desc,pri,watchdog_tm,tsk_class);
            obj.TaskList{end+1}=task;
        end

        function task=createPeriodicTask(obj,name,desc,pri,watchdog_tm,tsk_class,rate)
            task=plccore.common.PeriodicTask(name,desc,pri,watchdog_tm,tsk_class,rate);
            obj.TaskList{end+1}=task;
        end

        function task=createEventTask(obj,name,desc,pri,watchdog_tm,tsk_class,rate,trigger)
            task=plccore.common.EventTask(name,desc,pri,watchdog_tm,tsk_class,rate,trigger);
            obj.TaskList{end+1}=task;
        end

        function ret=hasTask(obj,name)
            ret=false;
            for i=1:length(obj.TaskList)
                if strcmp(obj.TaskList{i}.name,name)
                    ret=true;
                    return;
                end
            end
        end

        function ret=getTask(obj,name)
            ret=[];
            for i=1:length(obj.TaskList)
                if strcmp(obj.TaskList{i}.name,name)
                    ret=obj.TaskList{i};
                    return;
                end
            end
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitConfiguration(obj,input);
        end
    end
end


