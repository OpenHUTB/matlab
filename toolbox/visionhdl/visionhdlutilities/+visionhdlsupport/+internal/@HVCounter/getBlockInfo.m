function blockInfo=getBlockInfo(this,hC)













    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;

        blockInfo.ActivePixelsPerLine=sysObjHandle.ActivePixelsPerLine;
        blockInfo.ActiveVideoLines=sysObjHandle.ActiveVideoLines;

    else
        bfp=hC.Simulinkhandle;

        blockInfo.ActivePixelsPerLine=this.hdlslResolve('ActivePixelsPerLine',bfp);
        blockInfo.ActiveVideoLines=this.hdlslResolve('ActiveVideoLines',bfp);

    end
