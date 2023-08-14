function P=computeExponentialAveraging(obj,Pall)




    lambda=obj.ForgettingFactor;

    w_N_1=obj.pPreviousWeight;
    w_N=lambda*w_N_1+1;


    P_N_1=obj.pPreviousExpAvgSpectrum;
    P=(1-1/w_N).*P_N_1+(1/w_N).*squeeze(Pall);
    obj.pPreviousWeight=w_N;
    obj.pPreviousExpAvgSpectrum=P;
end
