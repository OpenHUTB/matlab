function blockInfo=getBlockInfo(this,hC)














    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;

        NumBins=sysObjHandle.NumBins;
        blockInfo.outputWL=sysObjHandle.OutputWL;

    else
        bfp=hC.Simulinkhandle;

        NumBins=get_param(bfp,'NumBins');
        blockInfo.outputWL=this.hdlslResolve('OutputWL',bfp);

    end
    numarr=NumBins-48;
    len=length(numarr);
    sums=0;
    for i=1:len
        sums=sums+numarr(i)*10.^(len-i);
    end
    binNumber=sums;
    binWL=floor(log2(binNumber));

    blockInfo.binNumber=binNumber;
    blockInfo.binWL=binWL;
end
