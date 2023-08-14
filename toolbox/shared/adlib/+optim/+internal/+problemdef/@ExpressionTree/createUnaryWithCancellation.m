function createUnaryWithCancellation(obj,Op,ExprLeft)













    if isa(ExprLeft.Root,'optim.internal.problemdef.UnaryExpressionImpl')&&...
        isa(ExprLeft.Root.Operator,class(Op))


        copy(obj,ExprLeft);

        obj.Stack(end)=[];

        obj.Depth=obj.Depth-1;

        obj.Type=computeType(obj);
    else

        createUnary(obj,Op,ExprLeft);
    end

end
