function[H,A,b]=extractQuadraticCoefficients(con,numVars)










    [H1,A1,b1]=extractQuadraticCoefficients(con.Expr1,numVars);


    [H2,A2,b2]=extractQuadraticCoefficients(con.Expr2,numVars);



    switch con.Relation
    case '>='
        H=combineHessians(H2,H1);
        A=A2-A1;
        b=b2(:)-b1(:);
    otherwise
        H=combineHessians(H1,H2);
        A=A1-A2;
        b=b1(:)-b2(:);
    end

end

function H=combineHessians(H_left,H_right)




    if isempty(H_left)
        H=-H_right;
    elseif isempty(H_right)
        H=H_left;
    else
        H=H_left-H_right;
    end

end
