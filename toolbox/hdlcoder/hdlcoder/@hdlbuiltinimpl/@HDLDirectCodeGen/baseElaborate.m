function hBlackBoxC=baseElaborate(this,hN,hC)

























    hBlackBoxC=createBlackBoxComp(this,hN,hC);

    if hC.hasGeneric
        hBlackBoxC.copyGenericsFrom(hC);
    end


    hN.replaceComponent(hC,hBlackBoxC);


