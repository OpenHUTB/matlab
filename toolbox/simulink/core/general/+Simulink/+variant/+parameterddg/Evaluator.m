classdef(Sealed,Hidden)Evaluator<handle






    properties(Access=private)
        fContext='';
    end

    methods
        function obj=Evaluator(aDlgContext)
            if nargin>0
                obj.fContext=aDlgContext;
            end
        end

        function assign(obj,aVariableName,aVariableValue)
            if isempty(obj.fContext)

                assignin('base',aVariableName,aVariableValue);
                return;
            end

            assignin(obj.fContext,aVariableName,aVariableValue);
        end

        function out=evalin(obj,aExpression)
            if isempty(obj.fContext)

                out=evalin('base',aExpression);
                return;
            end

            out=evalin(obj.fContext,aExpression);
        end
    end
end
