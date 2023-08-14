function blockInfo=getBlockInfo(this,hC)




    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;








        h=clone(sysObjHandle);
        ipType=hC.PirInputSignals(1).Type;
        if isa(ipType,'hdlcoder.tp_double')
            ipData=0;
        elseif ipType.Signed==1&&ipType.WordLength==8&&ipType.FractionLength==0
            ipData=int8(0);
        elseif ipType.Signed==1&&ipType.WordLength==16&&ipType.FractionLength==0
            ipData=int16(0);
        else
            ipData=fi(0,ipType.Signed,ipType.WordLength,-(ipType.FractionLength));

        end
        ipControl=pixelcontrolstruct;
        h.setup(ipData,ipControl);
        h.reset();
        ds=h.getDiscreteState;
        blockInfo.LUT=ds.Table;

    else
        bfp=hC.Simulinkhandle;
        rto=get_param(bfp,'RunTimeObject');
        blockInfo.LUT=rto.Dwork(1).Data;
    end


    rtype=this.getImplParams('LUTRegisterResetType');
    if isempty(rtype)
        resetnone=false;
    else
        resetnone=strncmpi(rtype,'none',4);
    end
    blockInfo.resetnone=resetnone;

    blockInfo.delay=2;

