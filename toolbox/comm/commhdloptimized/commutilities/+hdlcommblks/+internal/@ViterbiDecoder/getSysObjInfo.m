function blockInfo=getSysObjInfo(this,sysObj)


























    blockInfo.hOutType=sysObj.OutputDataType;

    blockInfo.trellis=sysObj.TrellisStructure;
    t=blockInfo.trellis;


    k=log2(t.numInputSymbols);
    n=log2(t.numOutputSymbols);
    nS=t.numStates;
    L=log2(nS)+1;

    blockInfo.k=k;
    blockInfo.n=n;
    blockInfo.L=L;

    blockInfo.IsPunctured=strcmp(sysObj.PuncturePatternSource,'Property');

    if sysObj.ErasuresInputPort
        blockInfo.erasures='on';
    else
        blockInfo.erasures='off';
    end

    dectypestr=sysObj.InputFormat;
    if strfind(dectypestr,'Hard')
        blockInfo.nsDec=1;
    elseif strfind(dectypestr,'Soft')
        blockInfo.nsDec=sysObj.SoftInputWordLength;
    else
        blockInfo.nsDec=0;
    end

    tbd=sysObj.TracebackDepth;
    blockInfo.tbd=tbd;

    blockInfo.opmode=sysObj.TerminationMethod;
    blockInfo.hasResetPort=sysObj.ResetInputPort;
    if blockInfo.hasResetPort
        blockInfo.DelayedResetAction=sysObj.DelayedResetAction;
    else
        blockInfo.DelayedResetAction=false;
    end
    if~strcmp(sysObj.InputFormat,'Unquantized')&&...
        strcmp(sysObj.StateMetricDataType,'Custom')
        blockInfo.smwl=sysObj.CustomStateMetricDataType.WordLength;
    else
        blockInfo.smwl=16;
    end


    tbcompnum=getChoice(this);

    if(isnumeric(tbcompnum))
        blockInfo.tbcompnum=tbcompnum;
        blockInfo.tbregnum=floor(tbd/tbcompnum);
    else
        blockInfo.tbcompnum=0;
        blockInfo.tbregnum=0;
    end



    blkIO_latency=4;
    adder_latency=ceil(log2(n))-1;
    minmax_latency=ceil(log2(t.numStates))+2;
    tb_latency=blockInfo.tbregnum;

    blockInfo.latency=blkIO_latency+adder_latency+minmax_latency+tb_latency;

end
