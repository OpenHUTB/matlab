function newC=elaborate(this,hN,hC)




    inp=hC.PirInputSignals;
    op=hC.PirOutputSignals;











    op.Preserve(true);


    repetitionCount=this.hdlslResolve('N',hC.SimulinkHandle);



    newC=pirelab.getRepeatComp(hN,inp,op,repetitionCount);
