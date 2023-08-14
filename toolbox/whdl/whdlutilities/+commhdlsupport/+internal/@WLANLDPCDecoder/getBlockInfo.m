function blockInfo=getBlockInfo(this,hC)









    bfp=hC.SimulinkHandle;

    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    if strcmpi(blockInfo.synthesisTool,'')
        blockInfo.ramAttr_dist='';
    else
        blockInfo.ramAttr_dist='distributed';
    end

    blockInfo.Standard=get_param(bfp,'Standard');
    blockInfo.Termination=get_param(bfp,'Termination');
    blockInfo.Algorithm=get_param(bfp,'Algorithm');
    blockInfo.ParityCheckStatus=strcmp(get_param(bfp,'ParityCheckStatus'),'on');

    if strcmpi(blockInfo.Algorithm,'Min-sum')
        blockInfo.ScalingFactor=1;
    else
        blockInfo.ScalingFactor=this.hdlslResolve('ScalingFactor',bfp);
    end

    blockInfo.SpecifyInputs=get_param(bfp,'SpecifyInputs');

    if strcmpi(blockInfo.Termination,'Early')
        m=this.hdlslResolve('MaxNumIterations',bfp);
        blockInfo.NumIterations=m;
    else
        if strcmpi(blockInfo.SpecifyInputs,'Property')
            m=this.hdlslResolve('NumIterations',bfp);
            blockInfo.NumIterations=m;
        else
            blockInfo.NumIterations=8;
        end
    end

    tp1info=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tp1info=tp1info;
    blockInfo.InputWL=tp1info.wordsize;
    blockInfo.InputFL=tp1info.binarypoint;
    blockInfo.VectorSize=tp1info.dims;

    if(strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax'))
        blockInfo.finalVec=24;
        blockInfo.shiftWL=7;
        blockInfo.memDepth=81;
        blockInfo.betadecmpWL=28;
    else
        blockInfo.finalVec=16;
        blockInfo.shiftWL=6;
        blockInfo.memDepth=42;
        blockInfo.betadecmpWL=22;
    end

    if blockInfo.VectorSize==1
        blockInfo.memDepth1=blockInfo.memDepth;
    else
        blockInfo.memDepth1=blockInfo.memDepth+8;
    end

    if blockInfo.ScalingFactor==1
        aFL=-blockInfo.InputFL;
    else
        aFL=-blockInfo.InputFL+4;
    end

    blockInfo.alphaWL=blockInfo.InputWL+blockInfo.InputFL+2+aFL;
    blockInfo.betaWL=blockInfo.InputWL+blockInfo.InputFL+aFL;
    blockInfo.minWL=blockInfo.betaWL-1;
    blockInfo.alphaFL=-aFL;
end
