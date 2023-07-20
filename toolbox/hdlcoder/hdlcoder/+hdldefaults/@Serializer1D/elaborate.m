function hNewC=elaborate(this,hN,hC)


    CInfo=this.getBlockInfo(hC);

    hNewC=pirelab.getSerializer1DComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    CInfo.Ratio,CInfo.IdleCycles,CInfo.validInPort,CInfo.startOutPort,CInfo.validOutPort,hC.Name);

end



