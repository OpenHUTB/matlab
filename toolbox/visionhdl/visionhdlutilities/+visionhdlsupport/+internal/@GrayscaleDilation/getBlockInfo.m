function blockInfo=getBlockInfo(this,hC)






    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        blockInfo.Neighborhood=sysObjHandle.Neighborhood;
        blockInfo.LineBufferSize=sysObjHandle.LineBufferSize;

    else

        bfp=hC.Simulinkhandle;
        blockInfo.Neighborhood=this.hdlslResolve('Neighborhood',bfp);
        blockInfo.LineBufferSize=(this.hdlslResolve('LineBufferSize',bfp))*2;

    end

    dim=size(blockInfo.Neighborhood);

    blockInfo.kHeight=dim(1);
    blockInfo.kWidth=dim(2);


    if blockInfo.kHeight>1&&any(blockInfo.Neighborhood(:)==false)||(blockInfo.kHeight>1&&blockInfo.kWidth==1)||blockInfo.kWidth<8
        blockInfo.Algorithm='fullTreeDilation';
    elseif blockInfo.kHeight>1&&all(blockInfo.Neighborhood(:)==true)
        blockInfo.Algorithm='decompositionDilation';
    else
        blockInfo.Algorithm='vanHerkDilation';
    end

end

