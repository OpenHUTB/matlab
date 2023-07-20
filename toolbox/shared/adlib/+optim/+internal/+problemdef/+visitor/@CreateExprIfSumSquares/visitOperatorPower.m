function visitOperatorPower(visitor,Op,Node)





    visitOperatorPower@optim.internal.problemdef.visitor.IsSumSquares(visitor,Op,Node);

    if visitor.ISS



        innerExponent=Op.Exponent/2;
        innerFactor=visitor.CurrentFactor;
        createMonomial(visitor,visitor.CurrentNodeIdx-1,innerExponent,innerFactor);
    end

end
