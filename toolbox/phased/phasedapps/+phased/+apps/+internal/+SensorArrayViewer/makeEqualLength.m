function[SA,F,PSB]=makeEqualLength(SA,F,PSB,NumSA,NumF,NumPSB)





    maxVectorLength=max([NumF,NumSA,NumPSB]);
    if NumSA==1
        SA=repmat(SA,1,maxVectorLength);
    end
    if NumF==1
        F=F*ones(1,maxVectorLength);
    end
    if NumPSB==1
        PSB=PSB*ones(1,maxVectorLength);
    end
end
