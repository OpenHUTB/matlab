function val=getValue(con,varVal)



























    varVal=optim.internal.problemdef.checkEvaluateInputs(con,varVal);





    lhsVal=evaluateNoCheck(con.Expr1,varVal);
    rhsVal=evaluateNoCheck(con.Expr2,varVal);
    switch con.Relation
    case '>='
        val=rhsVal-lhsVal;
    case '<='
        val=lhsVal-rhsVal;
    case '=='
        val=abs(rhsVal-lhsVal);
    otherwise




        val=zeros(size(con));
    end




