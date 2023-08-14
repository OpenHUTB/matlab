function hNewC=elaborate(this,hN,hC)




    opMode=getBlockInfo(this,hC);


    newComp=pirelab.getComplex2RealImag(hN,hC.SLInputSignals,hC.SLOutputSignals,opMode,hC.Name);

    hNewC=newComp;

end



