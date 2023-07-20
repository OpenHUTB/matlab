function opType=getBlockInfo(this,hC)



    slbh=hC.SimulinkHandle;

    opType=get_param(slbh,'Output');
