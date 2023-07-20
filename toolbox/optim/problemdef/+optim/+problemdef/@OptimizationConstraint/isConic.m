function isconic=isConic(con)







    if isNonlinear(con)

        [issqrt1,eout1,~,a1]=createExprIfSqrt(con.Expr1);
        [issqrt2,eout2,~,a2]=createExprIfSqrt(con.Expr2);



        if~xor(issqrt1,issqrt2)
            isconic=false;
            return
        end












        isLinearEout1=getExprType(eout1)<=optim.internal.problemdef.ImplType.Linear;
        isLinearEout2=getExprType(eout2)<=optim.internal.problemdef.ImplType.Linear;
        isEout1CoeffConic=(all(a1>0)&&strcmp(con.Relation,"<="))||...
        (all(a1<0)&&strcmp(con.Relation,">="));
        isEout2CoeffConic=(all(a2>0)&&strcmp(con.Relation,">="))||...
        (all(a2<0)&&strcmp(con.Relation,"<="));
        isconic=(issqrt1&&isQuadratic(eout1)&&isSumSquares(eout1)&&isEout1CoeffConic&&isLinearEout2)||...
        (issqrt2&&isQuadratic(eout2)&&isSumSquares(eout2)&&isEout2CoeffConic&&isLinearEout1);
    else
        isconic=false;
    end
