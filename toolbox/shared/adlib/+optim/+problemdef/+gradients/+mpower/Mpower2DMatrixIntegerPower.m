function jacMpowerTrans=Mpower2DMatrixIntegerPower(opExpr,exponent)














    M=size(opExpr,1);
    N=exponent;

    if N==0

        jacMpowerTrans=sparse(M.^2,M.^2);
        return;
    elseif N==1

        jacMpowerTrans=speye(M.^2);
        return;
    end


    baseLeft=opExpr;
    baseRight=kron(opExpr,speye(M));


    partialTerms=cell(N,1);


    partialTerms{1}=1;



    for idx=2:N
        partialTerms{idx}=baseRight*partialTerms{idx-1};
    end

    jacMpowerTrans=partialTerms{end};

    for idx=(N-1):-1:2
        jacMpowerTrans=jacMpowerTrans+kron(speye(M),baseLeft.')*partialTerms{idx};
        baseLeft=opExpr*baseLeft;
    end
    jacMpowerTrans=jacMpowerTrans+kron(speye(M),baseLeft.')*partialTerms{1};

end
