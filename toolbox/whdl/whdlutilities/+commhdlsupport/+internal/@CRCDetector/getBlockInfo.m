function blockInfo=getBlockInfo(this,hC)













    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tpinfo=tpinfo;
    if tpinfo.isscalar
        blockInfo.dlen=tpinfo.wordsize;
    else
        blockInfo.dlen=tpinfo.dims;
    end

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;

        p=sysObjHandle.Polynomial;
        blockInfo.Polynomial=reshape(p,1,length(p));
        blockInfo.ReflectInput=sysObjHandle.ReflectInput;
        blockInfo.ReflectCRCChecksum=sysObjHandle.ReflectCRCChecksum;

        blockInfo.CRClen=length(blockInfo.Polynomial)-1;

        if sysObjHandle.DirectMethod
            initstate=crcConvInits(sysObjHandle.InitialState,p(2:end));
            blockInfo.InitialState=initstate(end:-1:1);
        else

            blockInfo.InitialState=sysObjHandle.InitialState;

        end
        blockInfo.FinalXorValue=sysObjHandle.FinalXORValue;

    else

        bfp=hC.Simulinkhandle;

        p=this.hdlslResolve('Polynomial',bfp);
        blockInfo.Polynomial=reshape(p,1,length(p));

        blockInfo.ReflectInput=strcmpi(get_param(bfp,'ReflectInput'),'on');
        blockInfo.ReflectCRCChecksum=strcmpi(get_param(bfp,'ReflectCRCChecksum'),'on');
        blockInfo.CRClen=length(blockInfo.Polynomial)-1;

        initstate=this.hdlslResolve('InitialState',bfp);
        if strcmpi(get_param(bfp,'DirectMethod'),'on')
            initstate=crcConvInits(initstate,p(2:end));
        end
        blockInfo.InitialState=initstate(end:-1:1);
        blockInfo.FinalXorValue=this.hdlslResolve('FinalXorValue',bfp);
    end
end
