function Pos=computeOneSidedSpectrum(obj,P)




    nfft=obj.pNFFT;
    if rem(nfft,2)
        select=1:(nfft+1)/2;
        Pos_unscaled=P(select,:);

        Pos=[Pos_unscaled(1,:);2*Pos_unscaled(2:end,:)];
    else
        select=1:nfft/2+1;
        Pos_unscaled=P(select,:);

        Pos=[Pos_unscaled(1,:);2*Pos_unscaled(2:end-1,:);Pos_unscaled(end,:)];
    end
end
