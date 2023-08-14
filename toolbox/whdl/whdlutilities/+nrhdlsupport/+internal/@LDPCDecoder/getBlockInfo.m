function blockInfo=getBlockInfo(this,hC)



















    bfp=hC.SimulinkHandle;
    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    if strcmpi(blockInfo.synthesisTool,'')
        blockInfo.ramAttr_dist='';
        blockInfo.ramAttr_block='';
    else
        blockInfo.ramAttr_dist='distributed';
        blockInfo.ramAttr_block='block';
    end

    blockInfo.Algorithm=get_param(bfp,'Algorithm');
    term=get_param(bfp,'Termination');
    if strcmpi(term,'Early')
        blockInfo.Termination='early';
    else
        blockInfo.Termination='max';
    end

    if strcmpi(blockInfo.Algorithm,'Min-sum')
        blockInfo.ScalingFactor=1;
    else
        blockInfo.ScalingFactor=this.hdlslResolve('ScalingFactor',bfp);
    end

    blockInfo.RateCompatible=strcmp(get_param(bfp,'RateCompatible'),'on');
    blockInfo.ParityCheckStatus=strcmp(get_param(bfp,'ParityCheckStatus'),'on');

    blockInfo.SpecifyInputs=get_param(bfp,'SpecifyInputs');


    if strcmpi(blockInfo.SpecifyInputs,'Property')
        if strcmpi(blockInfo.Termination,'early')
            m=this.hdlslResolve('MaxNumIterations',bfp);
            blockInfo.NumIterations=m;
        else
            m=this.hdlslResolve('NumIterations',bfp);
            blockInfo.NumIterations=m;
        end
    else
        blockInfo.NumIterations=8;
    end



    tp1info=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tp1info=tp1info;
    blockInfo.InputWL=tp1info.wordsize;
    blockInfo.InputFL=tp1info.binarypoint;
    blockInfo.VectorSize=tp1info.dims;

    if blockInfo.ScalingFactor==1
        aFL=-blockInfo.InputFL;
    else
        aFL=-blockInfo.InputFL+4;
    end

    blockInfo.alphaWL=blockInfo.InputWL+blockInfo.InputFL+2+aFL;
    if strcmpi(blockInfo.Termination,'early')&&(blockInfo.ScalingFactor~=1&&blockInfo.ScalingFactor~=0.75)
        blockInfo.betaWL=blockInfo.InputWL+blockInfo.InputFL+aFL+1;
        blockInfo.minWL=blockInfo.InputWL+blockInfo.InputFL-1+aFL+1;
    else
        blockInfo.betaWL=blockInfo.InputWL+blockInfo.InputFL+aFL;
        blockInfo.minWL=blockInfo.InputWL+blockInfo.InputFL-1+aFL;
    end

    blockInfo.betadecmpWL=2*(blockInfo.minWL);
    blockInfo.alphaFL=-aFL;


    if blockInfo.VectorSize==64
        blockInfo.memDepth=384;
    else
        blockInfo.memDepth=64;
    end

    if(blockInfo.InputWL==4||blockInfo.InputWL==5||blockInfo.InputWL==6)
        blockInfo.RAMOptimize=true;
        if blockInfo.ScalingFactor==1
            blockInfo.RAMOptFactor=4;
        else
            blockInfo.RAMOptFactor=2;
        end
    else
        blockInfo.RAMOptimize=false;
        blockInfo.RAMOptFactor=1;
    end

end
