function retval=usesSimulinkHandleForModelGen(this,hN,hC)





    slbh=hC.SimulinkHandle;
    retval=strcmp(get_param(slbh,'Mask'),'on');
