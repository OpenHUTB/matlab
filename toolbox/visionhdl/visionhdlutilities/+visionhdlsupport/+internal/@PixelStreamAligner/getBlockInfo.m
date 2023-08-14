function blockInfo=getBlockInfo(this,hC)













    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;

        blockInfo.LineBufferSize=sysObjHandle.LineBufferSize;
        blockInfo.MaximumNumberOfLines=sysObjHandle.MaximumNumberOfLines;

    else
        bfp=hC.Simulinkhandle;

        blockInfo.LineBufferSize=this.hdlslResolve('LineBufferSize',bfp);
        blockInfo.MaximumNumberOfLines=this.hdlslResolve('MaximumNumberOfLines',bfp);

    end
