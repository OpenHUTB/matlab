function blockInfo=getBlockInfo(this,hC)








    bfp=hC.Simulinkhandle;

    configFromPort=strcmp(get_param(bfp,'ConfigurationSource'),'Input port');
    downlinkMode=strcmp(get_param(bfp,'LinkDirection'),'Downlink');
    rntiFromPort=strcmp(get_param(bfp,'TargetRNTIPort'),'on')&&downlinkMode;
    debugPortsEn=strcmp(get_param(bfp,'DebugPortsEn'),'1');
    outputCRCBits=strcmp(get_param(bfp,'OutputCRCBits'),'on');
    listLength=str2num(get_param(bfp,'ListLength'));
    coreOrder=16;
    dupLimOpts=[6,7,8];

    blockInfo.configFromPort=configFromPort;
    blockInfo.downlinkMode=downlinkMode;
    blockInfo.rntiFromPort=rntiFromPort;
    blockInfo.debugPortsEn=debugPortsEn;
    blockInfo.outputCRCBits=outputCRCBits;
    blockInfo.listLength=listLength;
    blockInfo.coreOrder=coreOrder;
    blockInfo.dupLim=dupLimOpts(log2(listLength));

    blockInfo.emlPath=fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@PolarDecoder','cgireml');

    if downlinkMode
        nMax=9;
        crcPoly='24C';
        KType=pir_ufixpt_t(8,0);
    else
        nMax=10;
        crcPoly='11';
        KType=pir_ufixpt_t(10,0);
    end

    blockInfo.nMax=nMax;
    blockInfo.crcPoly=crcPoly;

    if configFromPort
        sequence=nrhdl.internal.PolarHelper.getSequence;
        sequence512=sequence(sequence<512);
        sequence256=sequence512(sequence512<256);
        sequence128=sequence256(sequence256<128);
        sequence64=sequence128(sequence128<64);
        sequence32=sequence64(sequence64<32);
        seqLut=[sequence32;sequence64;sequence128;sequence256;sequence512];
        if~downlinkMode
            seqLut=[seqLut;sequence];
        end
        seqAddrType=pir_ufixpt_t(nMax+1,0);

        itlvPattern=nrhdl.internal.PolarHelper.getItlvPattern;
        PLut=nrhdl.internal.PolarHelper.getSubblockItlvPattern;
        rowWeightLUT=nrhdl.internal.PolarHelper.getRowWeights(1024);

        blockInfo.seqLut=seqLut;
        blockInfo.seqAddrType=seqAddrType;
        blockInfo.itlvPattern=itlvPattern;
        blockInfo.PLut=PLut;
        blockInfo.rowWeightLUT=rowWeightLUT;
    else
        messageLength=this.hdlslResolve('MessageLength',bfp);
        rate=this.hdlslResolve('Rate',bfp);
        [n,N]=nrhdl.internal.PolarHelper.getN(messageLength,rate,nMax);
        [FLut,qPCProp]=nrhdl.internal.PolarHelper.construct(messageLength,rate,N);
        parityEnProp=messageLength>=18&&messageLength<=25;

        blockInfo.messageLength=messageLength;
        blockInfo.rate=rate;
        blockInfo.n=n;
        blockInfo.N=N;
        blockInfo.FLut=FLut;
        blockInfo.qPCProp=qPCProp;
        blockInfo.parityEnProp=parityEnProp;

        if downlinkMode
            itlvLut=nrhdl.internal.PolarHelper.interleaveMap(messageLength);
            blockInfo.itlvLut=itlvLut;
        end
    end


    insignals=hC.PirInputSignals;
    dataType=insignals(1).Type.BaseType;
    inWL=dataType.WordLength;
    llrReinType=pir_sfixpt_t(inWL,-inWL+1);
    intLlrType=pir_sfixpt_t(inWL+2,-inWL+1);
    intLlrSatLim=reinterpretcast(fi(2.^(inWL+2)-1,1,inWL+2,0),numerictype(1,inWL+2,inWL-1));

    stageType=pir_ufixpt_t(ceil(log2(nMax)),0);
    blockType=pir_ufixpt_t(nMax-log2(coreOrder)-1,0);
    concatBetaType=pir_ufixpt_t(listLength,0);
    pathType=pir_ufixpt_t(ceil(log2(listLength)),0);
    decType=pir_ufixpt_t(1,0);
    metricType=pir_ufixpt_t(inWL+6,-inWL+1);
    nType=pir_ufixpt_t(4,0);
    NType=pir_ufixpt_t(nMax,0);
    KInType=pir_ufixpt_t(10,0);
    EType=pir_ufixpt_t(14,0);
    targetRntiType=pir_ufixpt_t(16,0);
    qPCType=pirelab.createPirArrayType(NType,[1,3]);

    blockInfo.llrReinType=llrReinType;
    blockInfo.intLlrType=intLlrType;
    blockInfo.intLlrSatLim=intLlrSatLim;
    blockInfo.stageType=stageType;
    blockInfo.blockType=blockType;
    blockInfo.concatBetaType=concatBetaType;
    blockInfo.pathType=pathType;
    blockInfo.decType=decType;
    blockInfo.metricType=metricType;
    blockInfo.nType=nType;
    blockInfo.NType=NType;
    blockInfo.KInType=KInType;
    blockInfo.KType=KType;
    blockInfo.EType=EType;
    blockInfo.targetRntiType=targetRntiType;
    blockInfo.qPCType=qPCType;
    if listLength==4
        sorterOps=cell(3,1);

        sorterOps{1}=[1,2;
        3,4].';
        sorterOps{2}=[1,3;
        2,4].';
        sorterOps{3}=[1,1;
        2,3;
        4,4].';
        blockInfo.sorterOps=sorterOps;

        blockInfo.sorterPipes=[0,1,0,0];
    elseif listLength==8
        sorterOps=cell(6,1);

        sorterOps{1}=[1,2;
        3,4;
        5,6;
        7,8].';
        sorterOps{2}=[1,3;
        2,4;
        5,7;
        6,8].';
        sorterOps{3}=[1,5;
        2,6;
        3,7;
        4,8].';
        sorterOps{4}=[1,1;
        2,3;
        4,4;
        5,5;
        6,7;
        8,8].';
        sorterOps{5}=[1,1;
        2,2;
        3,5;
        4,6;
        7,7;
        8,8].';
        sorterOps{6}=[1,1;
        2,3;
        4,5
        6,7
        8,8].';

        blockInfo.sorterOps=sorterOps;

        blockInfo.sorterPipes=[1,0,1,0,1,0,1];
    end



    tpinfo=pirgetdatatypeinfo(decType);

    blockInfo.tpinfo=pir_ufixpt_t(1,0);
    blockInfo.dlen=tpinfo.wordsize;

    if downlinkMode
        blockInfo.Polynomial=[1,1,0,1,1,0,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1];
    else
        blockInfo.Polynomial=[1,1,1,0,0,0,1,0,0,0,0,1];
    end

    blockInfo.ParityPolynomial=[1,1,0,0,0,0,1];
    blockInfo.ParityCRClen=length(blockInfo.ParityPolynomial)-1;

    blockInfo.ReflectInput=false;
    blockInfo.ReflectCRCChecksum=false;
    blockInfo.CRClen=length(blockInfo.Polynomial)-1;

    blockInfo.InitialState=0;
    blockInfo.outputRnti=strcmp(get_param(bfp,'RNTIPort'),'on');
    blockInfo.FinalXorValue=false(1,blockInfo.CRClen);

    if blockInfo.outputRnti||blockInfo.rntiFromPort
        crcErrType=pir_ufixpt_t(blockInfo.CRClen,0);
        parityCrcErrType=pir_ufixpt_t(blockInfo.ParityCRClen,0);
    else
        crcErrType=pir_boolean_t;
        parityCrcErrType=pir_boolean_t;
    end

    blockInfo.crcErrType=crcErrType;
    blockInfo.parityCrcErrType=parityCrcErrType;

    if blockInfo.outputRnti
        errType=pir_ufixpt_t(blockInfo.CRClen,0);
    else
        errType=pir_boolean_t;
    end

    blockInfo.errType=errType;
end
