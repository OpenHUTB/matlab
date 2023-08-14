function blockInfo=getBlockInfo(this,hC)













    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tpinfo=tpinfo;
    blockInfo.dlen=tpinfo.wordsize;
    blockInfo.flen=tpinfo.binarypoint;
    blockInfo.issigned=tpinfo.issigned;

    bfp=hC.SimulinkHandle;

    blockInfo.OperationMode=get_param(bfp,'OperationMode');
    blockInfo.SpecifyInputs=get_param(bfp,'SpecifyInputs');

    if(strcmpi(blockInfo.SpecifyInputs,'Property'))
        p=this.hdlslResolve('PuncturingVector',bfp);

        blockInfo.PuncturingVector=reshape(p,1,length(p));
        blockInfo.PuncturingLength=length(blockInfo.PuncturingVector);
    else
        puncinfo=pirgetdatatypeinfo(hC.PirInputSignals(2).Type);

        blockInfo.PuncturingLength=puncinfo.vector(1);
    end
end