function blockInfo=getBlockInfo(this,hC)






    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        blockInfo.Algorithm=sysObjHandle.Algorithm;
        blockInfo.SensorAlignment=sysObjHandle.SensorAlignment;
        blockInfo.MaxLineSize=sysObjHandle.LineBufferSize;

    else

        bfp=hC.Simulinkhandle;
        blockInfo.Algorithm=get_param(bfp,'Algorithm');
        blockInfo.SensorAlignment=get_param(bfp,'SensorAlignment');
        blockInfo.MaxLineSize=this.hdlslResolve('LineBufferSize',bfp);


    end

