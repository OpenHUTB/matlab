classdef ( Sealed, Hidden )IfBlock < simscape.battery.internal.sscinterface.ConditionalBlock





    properties ( Constant )
        Type = "IfBlock";
    end

    properties ( Constant, Access = protected )
        Operator = "if";
    end

    properties ( Access = protected )
        Condition
    end

    methods
        function obj = IfBlock( condition )

            arguments
                condition string{ mustBeTextScalar, mustBeNonzeroLengthText }
            end

            obj.Condition = condition;
        end
    end
end

