function blockInfo=getBlockInfo(this,hC)










    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;

        Nhood=sysObjHandle.Neighborhood;
        lSize=sysObjHandle.LineBufferSize;
        pmethod=sysObjHandle.PaddingMethod;

    else
        bfp=hC.Simulinkhandle;
        Nhood=this.hdlslResolve('Neighborhood',bfp);
        lSize=this.hdlslResolve('LineBufferSize',bfp);
        pmethod=get_param(bfp,'PaddingMethod');
    end
    blockInfo.Nhood=Nhood;
    [blockInfo.kHeight,blockInfo.kWidth]=size(Nhood);
    blockInfo.LinebufferSize=lSize;
    blockInfo.PaddingMethod=pmethod;
