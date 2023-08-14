function blockInfo=getBlockInfo(this,hC)%#ok





    slbh=hC.SimulinkHandle;

    blockInfo.ic=hdlslResolve('ic',slbh);


