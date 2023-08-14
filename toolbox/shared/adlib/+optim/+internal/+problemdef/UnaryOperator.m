classdef UnaryOperator<optim.internal.problemdef.Operator







    properties(Hidden,SetAccess=private,GetAccess=public)
        UnaryOperatorVersion=1;
    end

    methods

        function op=UnaryOperator()
        end
    end

    methods(Access=protected,Static)

        function ok=checkIsValid(~,~)

            ok=true;
        end
    end

end
