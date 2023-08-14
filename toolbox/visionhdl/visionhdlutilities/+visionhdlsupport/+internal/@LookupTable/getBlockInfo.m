function blockInfo=getBlockInfo(this,hC)




    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo.LUT=sysObjHandle.Table;
    else
        bfp=hC.Simulinkhandle;
        blockInfo.LUT=this.hdlslResolve('Table',bfp);
    end


    rtype=this.getImplParams('LUTRegisterResetType');
    if isempty(rtype)
        resetnone=false;
    else
        resetnone=strncmpi(rtype,'none',4);
    end
    blockInfo.resetnone=resetnone;

    blockInfo.delay=2;
