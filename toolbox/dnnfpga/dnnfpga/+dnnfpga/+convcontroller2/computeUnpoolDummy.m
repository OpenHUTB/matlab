function[doneOut,zAddr,rtzOut,firstWrite,finalWrite,rtzSel,rSel,windx,...
    rtWeOut,dwx,dwy,wValid,mpwValid,r,c,rtxModK,rtyModK,state]=...
    computeUnpoolDummy(firstWritePos,finalWriteSize,resultSizeDivByOpW,zAddrW,...
    imgAddrW,dwLimit,unpoolKernelAddrW,convIndexActsBurstLengthAddrW)

%#codegen
    coder.allowpcode('plain');







    persistent rty;
    persistent rtx;

    persistent ryMod;
    persistent rxMod;


    persistent rtyMod;
    persistent rtyQuo;
    persistent rtxMod;
    persistent rtxQuo;

    persistent done;
    persistent STATE;


    persistent rtWeOut_;
    persistent dwx_;
    persistent dwy_;



    if isempty(STATE)
        rty=fi(0,0,imgAddrW,0);
        rtx=fi(0,0,imgAddrW,0);

        ryMod=fi(0,0,ceil(log2(3)),0);
        rxMod=fi(0,0,ceil(log2(3)),0);

        rtyMod=fi(0,0,ceil(log2(3)),0);
        rtyQuo=fi(0,0,zAddrW,0);
        rtxMod=fi(0,0,ceil(log2(3)),0);
        rtxQuo=fi(0,0,zAddrW,0);

        STATE=fi(0,0,ceil(log2(8)),0);
        done=false;

        rtWeOut_=fi(zeros([3*3,1]),0,1,0);
        dwx_=fi(0,0,ceil(log2(dwLimit)),0);
        dwy_=fi(0,0,ceil(log2(dwLimit)),0);
    end



    doneOut=done;
    zAddr=fi(zeros([3*3,1]),1,zAddrW*2+1,0);
    wValid=fi(false([1,9]),0,1,0);
    mpwValid=fi(false([1,3*3]),0,1,0);
    rtzOut=rtyQuo+rtxQuo*resultSizeDivByOpW(2);
    firstWrite=rtx>=firstWritePos(1)&&rtx<firstWritePos(2)&&rty>=firstWritePos(3)&&rty<firstWritePos(4);
    finalWrite=rtx<finalWriteSize(1)&&rty<finalWriteSize(2);
    rtzSel=rtxMod+rtyMod*3;
    rSel=rxMod+ryMod*3;
    windx=fi(0,0,convIndexActsBurstLengthAddrW,0);
    rtWeOut=rtWeOut_;
    rtWeOut(rtzSel+1)=fi(0,0,1,0);
    dwx=dwx_;
    dwy=dwy_;
    r=fi(rtx*ones([3*3,1]),0,imgAddrW,0);
    c=fi(rty*ones([3*3,1]),0,imgAddrW,0);
    state=STATE;
    rtxModK=fi(0,0,unpoolKernelAddrW,0);
    rtyModK=fi(0,0,unpoolKernelAddrW,0);
end
