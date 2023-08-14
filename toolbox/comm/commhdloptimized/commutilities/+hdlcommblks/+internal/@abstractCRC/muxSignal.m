function muxSignal(~,hN,sArray,sVector)





    dim=length(sArray);

    muxin=[];
    for i=1:dim

        muxin=[muxin,sArray(i)];
    end

    pirelab.getMuxComp(hN,muxin,sVector);
end
