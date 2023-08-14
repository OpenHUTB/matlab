function blockInfo=getBlockInfo(this,hC)






    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        blockInfo.Neighborhood=sysObjHandle.Neighborhood;
        blockInfo.LineBufferSize=sysObjHandle.LineBufferSize;

    else

        bfp=hC.Simulinkhandle;
        blockInfo.Neighborhood=this.hdlslResolve('Neighborhood',bfp);
        blockInfo.LineBufferSize=this.hdlslResolve('LineBufferSize',bfp);

    end

    dim=size(blockInfo.Neighborhood);

    blockInfo.kHeight=dim(1);
    blockInfo.kWidth=dim(2);




end

