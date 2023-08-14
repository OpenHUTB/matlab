classdef ASTVariable<handle




    properties

Name

        Value=[];


        IsOptimExpr=false;

        InitialValue=[];


        IsLHS=false;


        LHSImpl=[];
    end

    methods


        function var=ASTVariable(name,value)

            var.Name=name;
            if nargin>1

                var.Value=value;
                var.InitialValue=value;

                var.IsOptimExpr=isa(value,'optim.problemdef.OptimizationExpression');
            end
        end


        function val=getValue(astVar)

            if~astVar.IsLHS||astVar.IsOptimExpr


                val=astVar.Value;
            else


                val=astVar.LHSImpl.Value;
            end
        end


        function[initExpr,hasInit]=retrieveInit(astVar,~)
            initExpr=astVar.InitialValue;
            hasInit=~isempty(initExpr);
        end

        function isLHS=isLHSVariable(var)
            isLHS=var.IsLHS;
        end

        function createLHSVariable(var,ptiesVisitor)


            initVal=var.Value;


            [var.Value,var.LHSImpl]=...
            optim.problemdef.OptimizationExpression.createLHSExpr(var.Name,ptiesVisitor);
            var.IsLHS=true;
            if~isempty(initVal)

                var.InitialValue=createStaticAssign(var.Value,initVal,ptiesVisitor);
            end
        end
    end
end
