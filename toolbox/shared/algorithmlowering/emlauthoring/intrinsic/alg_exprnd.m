function[r]=alg_exprnd(mu,urand)












%#codegen
    if mu<0

        r=NaN;
    else

        r=-mu.*log(urand);
    end

