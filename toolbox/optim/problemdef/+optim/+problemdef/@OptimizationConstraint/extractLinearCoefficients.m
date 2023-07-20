function[A,b]=extractLinearCoefficients(con,numVars)









    [A1,b1]=extractLinearCoefficients(con.Expr1,numVars);


    [A2,b2]=extractLinearCoefficients(con.Expr2,numVars);






    switch con.Relation
    case '>='
        A=A2-A1;
        b=b1(:)-b2(:);
    otherwise
        A=A1-A2;
        b=b2(:)-b1(:);
    end
