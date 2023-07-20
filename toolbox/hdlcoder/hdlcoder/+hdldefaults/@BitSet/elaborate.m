function hNewC=elaborate(this,hN,hC)


    compName=hC.Name;
    sInfo=this.getStateInfo(hC);
    isBitSet=strcmp(sInfo.MaskType,'Bit Set');
    bitIndex=sInfo.iBit+1;

    hNewC=pirelab.getBitSetComp(hN,hC.SLInputSignals,hC.SLOutputSignals,isBitSet,bitIndex,compName);
