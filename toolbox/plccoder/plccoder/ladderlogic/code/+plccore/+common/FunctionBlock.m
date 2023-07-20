classdef FunctionBlock<plccore.common.POU




    properties(Access=protected)
LogicRoutineName
LogicRoutine
PrescanRoutineName
PrescanRoutine
EnableInFalseRoutineName
EnableInFalseRoutine
    end

    methods
        function obj=FunctionBlock(name,input_scope,output_scope,inout_scope,local_scope,arglist)
            obj@plccore.common.POU(name,input_scope,output_scope,inout_scope,local_scope);
            obj.Kind='FunctionBlock';
            if(nargin>5)
                obj.setArgList(arglist);
            end

            obj.LogicRoutineName='Logic';
            obj.LogicRoutine=[];
            obj.PrescanRoutineName='Prescan';
            obj.PrescanRoutine=[];
            obj.EnableInFalseRoutineName='EnableInFalse';
            obj.EnableInFalseRoutine=[];
        end

        function routine=createRoutine(obj,name)
            routine=plccore.common.Routine(name,obj);
            obj.LocalScope.addSymbol(name,routine);
        end

        function ret=hasLogicRoutine(obj)
            ret=~isempty(obj.logicRoutine);
        end

        function ret=hasPrescanRoutine(obj)
            ret=~isempty(obj.prescanRoutine);
        end

        function ret=hasEnableInFalseRoutine(obj)
            ret=~isempty(obj.enableInFalseRoutine);
        end

        function ret=enableInFalseRoutine(obj)
            if isempty(obj.EnableInFalseRoutine)
                if obj.localScope.hasSymbol(obj.EnableInFalseRoutineName)
                    obj.EnableInFalseRoutine=obj.localScope.getSymbol(obj.EnableInFalseRoutineName);
                end
            end
            ret=obj.EnableInFalseRoutine;
        end

        function ret=prescanRoutine(obj)
            if isempty(obj.PrescanRoutine)
                if obj.localScope.hasSymbol(obj.PrescanRoutineName)
                    obj.PrescanRoutine=obj.localScope.getSymbol(obj.PrescanRoutineName);
                end
            end
            ret=obj.PrescanRoutine;
        end

        function ret=logicRoutine(obj)
            if isempty(obj.LogicRoutine)
                if obj.localScope.hasSymbol(obj.LogicRoutineName)
                    obj.LogicRoutine=obj.localScope.getSymbol(obj.LogicRoutineName);
                end
            end
            ret=obj.LogicRoutine;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitFunctionBlock(obj,input);
        end
    end
end


