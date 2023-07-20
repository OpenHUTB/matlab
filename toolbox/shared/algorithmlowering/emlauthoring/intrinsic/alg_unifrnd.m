function[r]=alg_unifrnd(a,b,urand)








%#codegen

    if a>b
        r=NaN;
    else

        a2=a/2;
        b2=b/2;
        mu=a2+b2;
        sig=b2-a2;

        r=mu+sig*(2*urand-1);
    end
