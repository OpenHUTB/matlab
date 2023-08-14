function dins=demuxSignal(~,hN,inSignal,sname)





    [indim,hBT]=pirelab.getVectorTypeInfo(inSignal);

    dmuxout=[];
    for i=1:indim
        dins(i)=hN.addSignal(hBT,[sname,num2str(i)]);
        dmuxout=[dmuxout,dins(i)];
    end

    pirelab.getDemuxComp(hN,inSignal,dmuxout);
end
