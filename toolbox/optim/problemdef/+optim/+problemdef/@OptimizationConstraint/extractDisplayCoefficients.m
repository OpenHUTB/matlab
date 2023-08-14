function[A,b,idxNumericLhs]=extractDisplayCoefficients(con,numVars)









    [A1,b1]=extractLinearCoefficients(con.Expr1,numVars);


    [A2,b2]=extractLinearCoefficients(con.Expr2,numVars);



    A=A1-A2;
    b=b2(:)-b1(:);




    idxNumericLhs=~any(A1,1);
    idxNumericRhs=~any(A2,1);
    idxNumericLhs=idxNumericLhs(:)&~idxNumericRhs(:);
    A(:,idxNumericLhs)=-A(:,idxNumericLhs);
    b(idxNumericLhs)=-b(idxNumericLhs);