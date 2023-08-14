function[isqrt,innerNodeIdx]=getInnerSqrtExpression(tree,rootNodeIdx)














    stack=tree.Stack;


    innerNodeIdx=rootNodeIdx;

    thisNode=stack{innerNodeIdx};
    if isa(thisNode,'optim.internal.problemdef.UnaryExpressionImpl')
        if isa(thisNode.Operator,'optim.internal.problemdef.operator.Sqrt')


            isqrt=true;
            innerNodeIdx=innerNodeIdx-1;
        elseif isa(thisNode.Operator,'optim.internal.problemdef.Power')
            exponent=thisNode.Operator.Exponent;
            if exponent==0.5


                isqrt=true;
                innerNodeIdx=innerNodeIdx-1;
            else
                isqrt=false;
            end
        else
            isqrt=false;
        end
    else
        isqrt=false;
    end

end
