function blockInfo=getBlockInfo(this,hC)


















    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tpinfo=tpinfo;
    blockInfo.dlen=tpinfo.wordsize;
    blockInfo.issigned=tpinfo.issigned;

    bfp=hC.SimulinkHandle;
    CL=this.hdlslResolve('ConstraintLength',bfp);
    CG=this.hdlslResolve('CodeGenerator',bfp);
    tbd=this.hdlslResolve('Tbd',bfp);

    blockInfo.OperationMode=get_param(bfp,'TerminationMethod');
    blockInfo.ConstraintLength=CL;
    blockInfo.CodeGenerator=CG;
    blockInfo.N=numel(CG);
    blockInfo.tbd=tbd;

    blockInfo.Trellis=poly2trellis(CL,CG);
    blockInfo.numStates=blockInfo.Trellis.numStates;

    erasureport=get_param(bfp,'ErasureInputPort');
    resetport=get_param(bfp,'ResetInputPort');

    if(strcmpi(erasureport,'off'))
        blockInfo.ErasurePort=false;
    else
        blockInfo.ErasurePort=true;
    end

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(strcmpi(resetport,'off'))
            blockInfo.ResetPort=false;
        else
            blockInfo.ResetPort=true;
        end
    else
        blockInfo.ResetPort=false;
    end



    numoutsym=2^(blockInfo.N);
    if(blockInfo.issigned)
        bmmax=(2^(blockInfo.dlen-1))*blockInfo.N;
        bmwordlen=(floor(log2(bmmax))+1)+1;
        btype=pir_sfixpt_t(bmwordlen,0);
        bmType=pirelab.getPirVectorType(btype,numoutsym);
    else
        bmmax=(2^(blockInfo.dlen)-1)*blockInfo.N;
        bmwordlen=(floor(log2(bmmax))+1);
        btype=pir_ufixpt_t(bmwordlen,0);
        bmType=pirelab.getPirVectorType(btype,numoutsym);
    end

    blockInfo.bmType=bmType;
    blockInfo.bmWL=bmwordlen;



    numbranchs=blockInfo.N;
    if(blockInfo.issigned)
        bmmin=-1*2^(blockInfo.dlen-1)*numbranchs;
        bmmax=2^(blockInfo.dlen-1)*numbranchs;
        blockInfo.stateMetMin=(CL-1)*bmmin;
        blockInfo.stateMetMax=(CL-1)*bmmax;
        blockInfo.stateMetWL=(floor(log2(2*(CL-1)*bmmax))+1)+2;
        stype=pir_sfixpt_t(blockInfo.stateMetWL,0);
        smVType=pirelab.getPirVectorType(stype,blockInfo.numStates);
    else
        bmmin=0;
        bmmax=(2^(blockInfo.dlen)-1)*numbranchs;
        blockInfo.stateMetMin=(CL-1)*bmmin;
        blockInfo.stateMetMax=(CL-1)*bmmax;
        blockInfo.stateMetWL=(floor(log2(2*(CL-1)*bmmax))+1)+1;
        stype=pir_ufixpt_t(blockInfo.stateMetWL,0);
        smVType=pirelab.getPirVectorType(stype,blockInfo.numStates);
    end
    blockInfo.smType=smVType;


    blockInfo.idxWL=CL-1;
    blockInfo.cntWL=ceil(log2(blockInfo.tbd));
    blockInfo.addrWL=ceil(log2(3*blockInfo.tbd));
    if(CL==9)
        blockInfo.ramWL=2^(CL-2);
    else
        blockInfo.ramWL=2^(CL-1);
    end

end