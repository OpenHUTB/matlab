function blockInfo=getBlockInfo(this,hC)%#ok





    slbh=hC.SimulinkHandle;

    blockInfo.N=hdlslResolve('N',slbh);
    blockInfo.B=hdlslResolve('B',slbh);
    blockInfo.intdelay=(0:blockInfo.B:blockInfo.B*(blockInfo.N-1))';
    blockInfo.ic=hdlslResolve('ic',slbh);
    blockInfo.isint=strcmpi(hdlgetblocklibpath(slbh),...
    ['commcnvintrlv2/Convolutional',newline,'Interleaver']);


