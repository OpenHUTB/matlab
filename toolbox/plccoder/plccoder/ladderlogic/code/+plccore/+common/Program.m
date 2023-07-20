classdef Program<plccore.common.POU




    properties(Access=protected)
        MainRoutineName;
MainRoutine
RoutineList
    end

    methods
        function obj=Program(name,input_scope,output_scope,inout_scope,local_scope,arglist)
            obj@plccore.common.POU(name,input_scope,output_scope,inout_scope,local_scope);
            obj.Kind='Program';
            if(nargin>5)
                obj.setArgList(arglist);
            end
            obj.MainRoutineName='';
            obj.MainRoutine=[];
            obj.RoutineList={};
        end

        function routine=createRoutine(obj,name)
            routine=plccore.common.Routine(name,obj);
            obj.LocalScope.addSymbol(name,routine);
            obj.RoutineList{end+1}=routine;
        end

        function ret=hasMainRoutine(obj)
            ret=~isempty(obj.mainRoutine);
        end

        function ret=mainRoutine(obj)
            if isempty(obj.MainRoutine)&&~isempty(obj.MainRoutineName)
                assert(obj.localScope.hasSymbol(obj.MainRoutineName));
                obj.MainRoutine=obj.localScope.getSymbol(obj.MainRoutineName);
            end
            ret=obj.MainRoutine;
        end

        function setMainRoutineName(obj,name)
            obj.MainRoutineName=name;
        end

        function ret=routineList(obj)
            ret=obj.RoutineList;
        end

        function setRoutineList(obj,routine_list)
            obj.RoutineList=routine_list;
        end

        function ret=toString(obj)
            ret=toString@plccore.common.POU(obj);
            if obj.hasMainRoutine
                ret=sprintf('%sProgram: %s, main routine: %s\n',ret,obj.name,obj.mainRoutine.name);
            end
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitProgram(obj,input);
        end
    end

end


