function blockInfo=getBlockInfo(this,hC)











    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tpinfo=tpinfo;
    if tpinfo.isscalar
        blockInfo.dlen=tpinfo.wordsize;
    else
        blockInfo.dlen=tpinfo.dims;
    end

    blockInfo.Scalar=tpinfo.isscalar;
    if blockInfo.dlen~=1
        blockInfo.Parallel=true;
    else
        blockInfo.Parallel=false;
    end

    bfp=hC.Simulinkhandle;

    switch get_param(bfp,'CRCType')
    case 'CRC6'
        blockInfo.Polynomial=[1,1,0,0,0,0,1];
        blockInfo.CRCType='CRC6';
    case 'CRC11'
        blockInfo.Polynomial=[1,1,1,0,0,0,1,0,0,0,0,1];
        blockInfo.CRCType='CRC11';
    case 'CRC16'
        blockInfo.Polynomial=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];
        blockInfo.CRCType='CRC16';
    case 'CRC24A'
        blockInfo.Polynomial=[1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
        blockInfo.CRCType='CRC24A';
    case 'CRC24B'
        blockInfo.Polynomial=[1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
        blockInfo.CRCType='CRC24B';
    case 'CRC24C'
        blockInfo.Polynomial=[1,1,0,1,1,0,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1];
        blockInfo.CRCType='CRC24C';
    otherwise
    end

    if strcmpi(blockInfo.CRCType,'CRC24C')
        blockInfo.EnableCRCMaskPort=strcmp(get_param(bfp,'EnableCRCMaskPort'),'on');
    else
        blockInfo.EnableCRCMaskPort=false;
    end

    blockInfo.ReflectInput=false;
    blockInfo.ReflectCRCChecksum=false;
    blockInfo.CRClen=length(blockInfo.Polynomial)-1;

    initstate=0;
    blockInfo.InitialState=initstate(end:-1:1);
    blockInfo.FinalXorValue=reshape(int2bit(0,blockInfo.CRClen),blockInfo.CRClen,[]).';

    blockInfo.RNTIPort=strcmp(get_param(bfp,'FullCheckSum'),'on');
end
