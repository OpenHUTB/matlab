function Pdc=centerDC(~,P)




    nfft=size(P,1);
    Pdc=fftshift(P,1);

    if~rem(nfft,2)


        Pdc=[Pdc(2:end,:);Pdc(1,:)];
    end
end
