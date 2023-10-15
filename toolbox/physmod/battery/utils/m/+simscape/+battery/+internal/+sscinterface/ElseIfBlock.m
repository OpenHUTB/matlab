classdef ( Sealed, Hidden )ElseIfBlock < simscape.battery.internal.sscinterface.ConditionalBlock




    properties ( Constant )
        Type = "ElseIfBlock";
    end

    properties ( Constant, Access = protected )
        Operator = "elseif";
    end

    properties ( Access = protected )
        Condition
    end

    methods
        function obj = ElseIfBlock( condition )


            arguments
                condition string{ mustBeTextScalar, mustBeNonzeroLengthText }
            end

            obj.Condition = condition;
        end
    end
end


