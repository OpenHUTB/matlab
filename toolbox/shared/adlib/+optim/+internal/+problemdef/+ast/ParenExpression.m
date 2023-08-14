classdef ParenExpression<handle




    properties

ASTVar

Subscripts
    end

    methods

        function obj=ParenExpression(var,index)
            obj.ASTVar=var;
            obj.Subscripts=index;
        end
    end
end
