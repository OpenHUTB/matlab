


classdef(Abstract,...
    AllowedSubclasses={
    ?sltest.assessments.Plus
    ?sltest.assessments.Minus
    ?sltest.assessments.Mtimes
    ?sltest.assessments.Le
    ?sltest.assessments.Lt
    ?sltest.assessments.Ge
    ?sltest.assessments.Gt
    ?sltest.assessments.Eq
    ?sltest.assessments.Ne
    })BinaryNumeric<sltest.assessments.Binary
    methods(Static,Access=protected,Hidden)
        function[expL,expR]=validateInputs(name,left,right)
            function res=getInternalOrNumeric(value)
                if isnumeric(value)
                    res=sltest.assessments.Constant(value);
                elseif isa(value,'sltest.assessments.Expression')
                    res=value;
                else
                    error(message('sltest:assessments:NotExpressionOrNumeric',inputname(1),name));
                end
            end

            try
                if~isa(left,'sltest.assessments.Expression')&&~isa(right,'sltest.assessments.Expression')
                    error(message('sltest:assessments:MissingExpression',name));
                end
                expL=getInternalOrNumeric(left);
                expR=getInternalOrNumeric(right);
            catch ME
                ME.throwAsCaller();
            end
        end
    end
end
