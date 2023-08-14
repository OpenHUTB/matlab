function blockInfo=getBlockInfo(this,hC)























    blockInfo.hOutType=hC.PirOutputSignals(1).Type.getLeafType;

    bfp=hC.Simulinkhandle;

    t=this.hdlslResolve('trellis',bfp);
    blockInfo.trellis=t;


    k=log2(t.numInputSymbols);
    n=log2(t.numOutputSymbols);
    nS=t.numStates;
    L=log2(nS)+1;

    blockInfo.k=k;
    blockInfo.n=n;
    blockInfo.L=L;

    blockInfo.IsPunctured=get_param(bfp,'IsPunctured');

    blockInfo.erasures=get_param(bfp,'erasures');

    dectypestr=get_param(bfp,'dectype');
    if strfind(dectypestr,'Hard')
        blockInfo.nsDec=1;
    elseif strfind(dectypestr,'Soft')
        blockInfo.nsDec=this.hdlslResolve('nsdecb',bfp);
    else
        blockInfo.nsDec=0;
    end

    tbd=this.hdlslResolve('tbdepth',bfp);
    blockInfo.tbd=tbd;

    blockInfo.opmode=get_param(bfp,'opmode');
    blockInfo.reset=get_param(bfp,'reset');
    blockInfo.smwl=this.hdlslResolve('SmWordLength',bfp);
    blockInfo.hasResetPort=false;




    blkIO_latency=4;
    adder_latency=ceil(log2(n))-1;
    minmax_latency=ceil(log2(t.numStates))+2;


    tb_latency=3*blockInfo.tbd+2;

    blockInfo.latency=blkIO_latency+adder_latency+minmax_latency+tb_latency;

end
