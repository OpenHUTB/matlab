function createUnaryWithSimplification(obj,Op,ExprLeft)












    canSimplify=false;
    if isa(ExprLeft.Root,'optim.internal.problemdef.UnaryExpressionImpl')
        if isa(ExprLeft.Root.Operator,'optim.internal.problemdef.operator.Sqrt')
            ExprLeft.Root.Operator=optim.internal.problemdef.Power(ExprLeft,0.5);
        end
        if isa(ExprLeft.Root.Operator,'optim.internal.problemdef.operator.PowerOperator')&&...
            isa(ExprLeft.Root.Operator,class(Op))
            exponent1=ExprLeft.Root.Operator.Exponent;
            exponent2=Op.Exponent;
            isInt1=exponent1==floor(exponent1);
            isInt2=exponent2==floor(exponent2);





            canSimplify=isa(ExprLeft.Root.Operator,'optim.internal.problemdef.Power')&&~(isInt1&&~isInt2);

            canSimplify=canSimplify||(isInt1&&isInt2);

        end
    end

    if canSimplify&&exponent1*exponent2==1

        createUnaryWithCancellation(obj,Op,ExprLeft);
    elseif canSimplify


        copy(obj,ExprLeft);




        Node=optim.internal.problemdef.UnaryExpressionImpl(Op,obj.Stack{end-1});

        Node.Operator=Node.Operator.simplify(ExprLeft.Root.Operator);

        obj.Stack{end}=Node;

        obj.Type=getOutputType(Op,obj.Type,[]);
    else

        createUnary(obj,Op,ExprLeft);
    end

end