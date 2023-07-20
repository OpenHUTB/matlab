function socConstraint=extractConicCoefficients(con,numVars)


















    [issqrt1,sumsq,c1,a]=createExprIfSqrt(con.Expr1);
    if issqrt1
        linexprUser=con.Expr2;
    else
        [~,sumsq,c1,a]=createExprIfSqrt(con.Expr2);
        linexprUser=con.Expr1;
    end


    [~,linexprInNorm,c2,idx]=createExprIfSumSquares(sumsq);


    for i=numel(idx):-1:1

        [A,b]=extractLinearCoefficients(linexprInNorm(idx{i}),numVars);
        b=-b+c2(i);







        linexprBound=(linexprUser(i)-c1(i))/a(i);


        [d,gamma]=extractLinearCoefficients(linexprBound,numVars);
        gamma=-gamma;


        socConstraint(i)=secondordercone(A',b,d,gamma);
    end
