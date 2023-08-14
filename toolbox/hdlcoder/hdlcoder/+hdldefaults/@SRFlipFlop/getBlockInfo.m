function initialQ=getBlockInfo(this,hC)





    slbh=hC.SimulinkHandle;
    initialQ=hdlslResolve('initial_condition',slbh);
end
