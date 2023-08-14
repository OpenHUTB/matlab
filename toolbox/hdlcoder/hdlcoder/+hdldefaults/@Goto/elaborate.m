function newComp=elaborate(this,hN,hC)



    [tagName,tagScope]=getTag(this,hC);

    gotoIn=hC.SLInputSignals(1);

    newComp=pirelab.getGotoComp(hN,gotoIn,tagName,tagScope,hC.Name);


    hC.addOutputPort;


    hS=newComp.PirOutputSignals;


    hS.addDriver(hC,0);

end