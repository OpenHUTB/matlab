function newComp=elaborate(this,hN,hC)



    [tagName,tagScope]=getTag(this,hC);

    fromOut=hC.SLOutputSignals(1);

    newComp=pirelab.getFromComp(hN,fromOut,tagName,tagScope,hC.Name);

end
