function blockInfo=getBlockInfo(~,hC)





    slbh=hC.SimulinkHandle;

    blockInfo=struct;
    blockInfo.latencyStrategy=(get_param(slbh,'latencyStrategy'));
    blockInfo.dotProductSize=hdlslResolve('dotProductSize',slbh);
    blockInfo.aRowSize=hdlslResolve('aRowSize',slbh);
    blockInfo.aColumnSize=hdlslResolve('aColumnSize',slbh);
    blockInfo.bColumnSize=hdlslResolve('bColumnSize',slbh);
    blockInfo.MajorOrder=(get_param(slbh,'MajorOrder'));
    if(strcmpi(blockInfo.MajorOrder,'Column'))
        temp=blockInfo.aRowSize;
        blockInfo.aRowSize=blockInfo.bColumnSize;
        blockInfo.bColumnSize=temp;
    end

end


