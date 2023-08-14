function[lambda,overwritten]=toleranceScaleFactor_private(type,percent,distribution,nSigma)%#codegen




    coder.allowpcode('plain');

    tol=percent/100;

    if type==0

        lambda=1;
        overwritten=0;

    elseif type==1

        rng('shuffle','twister')

        if distribution==1


            X=rand;
            lambda=(1-tol+2*tol*X);
            overwritten=0;

        else


            if nSigma>0
                Sigma=tol/nSigma;
            else
                Sigma=0;
            end
            X=randn;
            lambda=(1+Sigma*X);
            if lambda<=0
                lambda=1;
                overwritten=1;
            else
                overwritten=0;
            end

        end

    elseif type==2

        lambda=(1+tol);
        overwritten=0;

    elseif type==3

        lambda=(1-tol);
        overwritten=0;

    else

        lambda=1;
        overwritten=0;

    end

end
