function blockInfo=getBlockInfo(this,hC)











    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tpinfo=tpinfo;
    blockInfo.vecsize=tpinfo.dims;
    blockInfo.dlen=tpinfo.wordsize;
    blockInfo.issigned=tpinfo.issigned;
    blockInfo.flen=tpinfo.binarypoint;
    blockInfo.InputDataIsReal=~tpinfo.iscomplex;

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo.NumCycles=sysObjHandle.NumCycles;
        blockInfo.SampleOffset=sysObjHandle.SampleOffset;
        blockInfo.UpsampleFactor=sysObjHandle.UpsampleFactor;
        blockInfo.ResetIn=sysObjHandle.ResetInputPort;
        blockInfo.inMode=[true;...
        sysObjHandle.ResetInputPort;
        sysObjHandle.ReadyPort];
    else


        slHandle=hC.Simulinkhandle;
        blockInfo.NumCycles=this.hdlslResolve('NumCycles',slHandle);
        blockInfo.SampleOffset=this.hdlslResolve('SampleOffset',slHandle);
        blockInfo.UpsampleFactor=this.hdlslResolve('UpsampleFactor',slHandle);
        blockInfo.ResetIn=strcmpi(get_param(slHandle,'ResetInputPort'),'on');
        blockInfo.inMode=[true;...
        strcmpi(get_param(slHandle,'ResetInputPort'),'on');
        strcmpi(get_param(slHandle,'ReadyPort'),'on')];
    end
    blockInfo.R1=blockInfo.UpsampleFactor*blockInfo.vecsize;
    blockInfo.R2=(blockInfo.UpsampleFactor*blockInfo.vecsize)/blockInfo.NumCycles;
    blockInfo.stageVecsize=blockInfo.UpsampleFactor/blockInfo.NumCycles;
    blockInfo.residueVect=rem(blockInfo.SampleOffset,blockInfo.R2);
    blockInfo.vecFlag=blockInfo.vecsize>1;
end