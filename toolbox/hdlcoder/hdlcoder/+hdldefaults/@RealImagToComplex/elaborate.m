function newComp=elaborate(this,hN,hC)




    [inputTypeMode,cval]=getBlockInfo(this,hC);


    newComp=pirelab.getRealImag2Complex(hN,hC.SLInputSignals,hC.SLOutputSignals,inputTypeMode,cval,hC.Name);

end



