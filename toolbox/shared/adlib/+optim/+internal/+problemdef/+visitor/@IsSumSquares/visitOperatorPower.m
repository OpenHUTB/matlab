function visitOperatorPower(visitor,Op,~)





    if Op.ExponentIsOptimExpr


        visitor.ISS=false;
        return;
    end

    if~mod(Op.Exponent,2)==0

        visitor.ISS=false;
    end

end
