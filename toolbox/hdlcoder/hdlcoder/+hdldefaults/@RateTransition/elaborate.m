function rtComp=elaborate(this,hN,hC)


    [initC,dintegrity_on,ddtransfer_on,~,outputRate]=this.getBlockInfo(hC);

    rtComp=pirelab.getRateTransitionComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    outputRate,initC,hC.Name,'',-1,dintegrity_on,ddtransfer_on);
end
