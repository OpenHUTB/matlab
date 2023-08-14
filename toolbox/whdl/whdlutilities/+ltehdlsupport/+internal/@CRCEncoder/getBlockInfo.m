function blockInfo=getBlockInfo(this,hC)













    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tpinfo=tpinfo;
    if tpinfo.isscalar
        blockInfo.dlen=tpinfo.wordsize;
    else
        blockInfo.dlen=tpinfo.dims;
    end

    bfp=hC.Simulinkhandle;

    switch get_param(bfp,'CRCType')
    case 'CRC8'
        blockInfo.Polynomial=[1,1,0,0,1,1,0,1,1];
    case 'CRC16'
        blockInfo.Polynomial=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];
    case 'CRC24A'
        blockInfo.Polynomial=[1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
    case 'CRC24B'
        blockInfo.Polynomial=[1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
    otherwise
    end
    blockInfo.ReflectInput=false;
    blockInfo.ReflectCRCChecksum=false;
    blockInfo.CRClen=length(blockInfo.Polynomial)-1;

    initstate=0;
    blockInfo.InitialState=initstate(end:-1:1);
    blockInfo.FinalXorValue=reshape(int2bit(this.hdlslResolve('FinalXorValue',bfp),blockInfo.CRClen),blockInfo.CRClen,[]).';
end
