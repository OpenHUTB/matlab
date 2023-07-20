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
        blockInfo.ResetIn=sysObjHandle.ResetInputPort;
        blockInfo.SampleOffset=sysObjHandle.SampleOffset;
        blockInfo.DownsampleFactor=sysObjHandle.DownsampleFactor;
        blockInfo.inMode=[true;...
        sysObjHandle.ResetInputPort];
    else


        slHandle=hC.Simulinkhandle;
        blockInfo.inMode=[true;...
        strcmpi(get_param(slHandle,'ResetInputPort'),'on')];
        blockInfo.ResetIn=strcmpi(get_param(slHandle,'ResetInputPort'),'on');
        blockInfo.SampleOffset=this.hdlslResolve('SampleOffset',slHandle);
        blockInfo.DownsampleFactor=this.hdlslResolve('DownsampleFactor',slHandle);
    end

    blockInfo.intOff=fi(floor(double(blockInfo.SampleOffset)/double(blockInfo.vecsize)),0,1+ceil(log2(blockInfo.DownsampleFactor)),0,hdlfimath);
    blockInfo.residue=fi(mod(double(blockInfo.SampleOffset),double(blockInfo.vecsize)),0,1+ceil(log2(blockInfo.DownsampleFactor)),0,hdlfimath);
    blockInfo.vecCount=(blockInfo.DownsampleFactor/blockInfo.vecsize)-1;
    blockInfo.numinputs=(ceil(double(blockInfo.vecsize)/double(blockInfo.DownsampleFactor)));
    tmp=(blockInfo.SampleOffset+1):blockInfo.DownsampleFactor:(blockInfo.SampleOffset+blockInfo.vecsize);
    blockInfo.index=coder.const(tmp);
    blockInfo.vecFlag=blockInfo.vecsize>blockInfo.DownsampleFactor;
    if blockInfo.vecsize<=blockInfo.DownsampleFactor
        blockInfo.numinputs=1;
    else
        blockInfo.numinputs=blockInfo.vecsize/blockInfo.DownsampleFactor;
    end
end