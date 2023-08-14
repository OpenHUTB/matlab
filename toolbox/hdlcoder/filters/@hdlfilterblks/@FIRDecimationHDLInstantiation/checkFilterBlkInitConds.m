function pass=checkFilterBlkInitConds(this,hC)






    bfp=hC.SimulinkHandle;
    initconds=hdlslResolve('outputBufInitCond',bfp);

    pass=~any(initconds);


