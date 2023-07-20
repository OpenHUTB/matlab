function lambda=aeroblklambdaWrap(lambda,phi_wrapped)






%#codegen

    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    if phi_wrapped
        lambda=lambda+pi;
    end
    flam=abs(lambda);
    slam=1.0;

    if flam>pi
        if lambda<-pi
            slam=-1.0;
        end
        lambda=slam*(mod(flam,2*pi)-...
        (2*pi)*floor(mod(flam,2*pi)/pi));
    end
end
