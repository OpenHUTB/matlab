function blockInfo=getBlockInfo(this,hC)






    blockInfo.Exposed=false;
    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        blockInfo.KernelHeight=sysObjHandle.NeighborhoodSize(1);
        blockInfo.KernelWidth=sysObjHandle.NeighborhoodSize(2);



        blockInfo.PaddingMethod=sysObjHandle.PaddingMethod;
        blockInfo.PaddingValue=sysObjHandle.PaddingValue;
        blockInfo.MaxLineSize=sysObjHandle.LineBufferSize;
        blockInfo.BiasUp=true;

    else

        bfp=hC.Simulinkhandle;
        KernelSize=this.hdlslResolve('NeighborhoodSize',bfp);
        blockInfo.KernelHeight=KernelSize(1);
        blockInfo.KernelWidth=KernelSize(2);







        blockInfo.PaddingMethod=get_param(bfp,'PaddingMethod');
        blockInfo.PaddingValue=this.hdlslResolve('PaddingValue',bfp);
        blockInfo.MaxLineSize=this.hdlslResolve('LineBufferSize',bfp);
        blockInfo.BiasUp=true;







    end

