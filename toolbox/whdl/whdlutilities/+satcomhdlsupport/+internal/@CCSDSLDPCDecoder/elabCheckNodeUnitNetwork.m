function cNet=elabCheckNodeUnitNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_boolean_t;
    cType=pir_ufixpt_t(blockInfo.vaddrWL,0);
    if blockInfo.memDepth==64
        signType=pir_ufixpt_t(32,0);
    else
        signType=pir_ufixpt_t(31,0);
    end

    scType=pirelab.getPirVectorType(signType,blockInfo.memDepth);
    bcType=pir_ufixpt_t(blockInfo.betaCompWL,0);
    bcType3=pir_ufixpt_t(blockInfo.betaIdxWL,0);
    bcType4=pir_ufixpt_t(2*blockInfo.minWL,0);
    mType=pir_ufixpt_t(blockInfo.minWL,blockInfo.alphaFL);
    m1Type=pir_ufixpt_t(blockInfo.minWL+1,blockInfo.alphaFL);
    bType=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);

    sType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);
    bcVType=pirelab.getPirVectorType(bcType,blockInfo.memDepth);
    bcVType3=pirelab.getPirVectorType(bcType3,blockInfo.memDepth);
    bcVType4=pirelab.getPirVectorType(bcType4,blockInfo.memDepth);
    minType=pirelab.getPirVectorType(mType,blockInfo.memDepth);
    min1Type=pirelab.getPirVectorType(m1Type,blockInfo.memDepth);
    idxType=pirelab.getPirVectorType(cType,blockInfo.memDepth);
    betaVType=pirelab.getPirVectorType(bType,blockInfo.memDepth);


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CheckNodeUnit',...
    'Inportnames',{'data','valid','count','reset','rdenable'},...
    'InportTypes',[betaVType,ufix1Type,cType,ufix1Type,sType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'cnuDecomp1','cnuDecomp2','cnuDecomp3','cnuDecomp4','cnuvalid'},...
    'OutportTypes',[bcVType,bcVType,bcVType3,bcVType4,ufix1Type]...
    );



    data=cNet.PirInputSignals(1);
    valid=cNet.PirInputSignals(2);
    count=cNet.PirInputSignals(3);
    reset=cNet.PirInputSignals(4);
    rdenable=cNet.PirInputSignals(5);

    cnu_decomp1=cNet.PirOutputSignals(1);
    cnu_decomp2=cNet.PirOutputSignals(2);
    cnu_decomp3=cNet.PirOutputSignals(3);
    cnu_decomp4=cNet.PirOutputSignals(4);
    cnu_valid=cNet.PirOutputSignals(5);


    data_reg=cNet.addSignal(data.Type,'dataReg');
    dataabs=cNet.addSignal(min1Type,'dataAbs');
    valid_reg=cNet.addSignal(valid.Type,'validReg');
    count_reg=cNet.addSignal(count.Type,'countReg');
    rdenable_reg=cNet.addSignal(rdenable.Type,'rdEnbReg');

    intreset=cNet.addSignal(reset.Type,'intReset');
    validD=cNet.addSignal(valid.Type,'validD');
    pirelab.getIntDelayComp(cNet,valid,validD,1,'');
    validDNeg=cNet.addSignal(valid.Type,'validDNeg');
    pirelab.getLogicComp(cNet,validD,validDNeg,'not');
    pirelab.getLogicComp(cNet,[valid,validDNeg],intreset,'and');

    extreset=cNet.addSignal(reset.Type,'extReset');
    pirelab.getLogicComp(cNet,[reset,intreset],extreset,'or');

    pirelab.getIntDelayComp(cNet,data,data_reg,2,'');
    pirelab.getIntDelayComp(cNet,valid,valid_reg,2,'');
    pirelab.getIntDelayComp(cNet,count,count_reg,2,'');
    pirelab.getIntDelayComp(cNet,rdenable,rdenable_reg,2,'');

    pirelab.getAbsComp(cNet,data_reg,dataabs);

    counti=cNet.addSignal(count.Type,'countU');
    min1=cNet.addSignal(min1Type,'minVal1');
    min2=cNet.addSignal(min1Type,'minVal2');
    minindex=cNet.addSignal(idxType,'minindex');
    signs1=cNet.addSignal(scType,'signs1');
    signs2=cNet.addSignal(scType,'signs2');
    prodsign=cNet.addSignal(sType,'prodsign');
    valido=cNet.addSignal(ufix1Type,'validD');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','minCalculation.m'),'r');
    minCalculation=fread(fid,Inf,'char=>char');
    fclose(fid);

    maxVal=(2^(blockInfo.betaWL-1)-1);
    mem=blockInfo.memDepth;
    bWL=blockInfo.betaWL;
    bFL=-blockInfo.alphaFL;

    const1=cNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(cNet,const1,1);

    pirelab.getAddComp(cNet,[count_reg,const1],counti,'Floor','Wrap','AddComp');

    cNet.addComponent2(...
    'kind','cgireml',...
    'Name','minCalculation',...
    'InputSignals',[data_reg,valid_reg,counti,extreset,dataabs,rdenable_reg],...
    'OutputSignals',[min1,min2,minindex,signs1,signs2,prodsign,valido],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','minCalculation',...
    'EMLFileBody',minCalculation,...
    'EmlParams',{maxVal,mem,bWL,bFL},...
    'EMLFlag_TreatInputIntsAsFixpt',true);


    psign_arr=this.demuxSignal(cNet,prodsign,'psign_array');
    minindex_arr=this.demuxSignal(cNet,minindex,'minindx_array');



    min1dtc=cNet.addSignal(minType,'min1_DTC');
    min2dtc=cNet.addSignal(minType,'min2_DTC');

    pirelab.getDTCComp(cNet,min1,min1dtc,'Floor','Saturate');
    pirelab.getDTCComp(cNet,min2,min2dtc,'Floor','Saturate');

    min1_arr=this.demuxSignal(cNet,min1dtc,'min1_array');
    min2_arr=this.demuxSignal(cNet,min2dtc,'min2_array');


    for idx=1:blockInfo.memDepth
        bcomp3_arr(idx)=cNet.addSignal(bcType3,['betacomp3_arr_',num2str(idx)]);%#ok<*AGROW>
        bcomp4_arr(idx)=cNet.addSignal(bcType4,['betacomp4_arr_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getBitConcatComp(cNet,[psign_arr(idx),minindex_arr(idx)],bcomp3_arr(idx),'bitConcat3');
        pirelab.getBitConcatComp(cNet,[min1_arr(idx),min2_arr(idx)],bcomp4_arr(idx),'bitConcat4');
    end

    betacomp1D=cNet.addSignal(cnu_decomp1.Type,'betacomp1D');
    betacomp2D=cNet.addSignal(cnu_decomp2.Type,'betacomp2D');
    betacomp3D=cNet.addSignal(cnu_decomp3.Type,'betacomp3D');
    betacomp4D=cNet.addSignal(cnu_decomp4.Type,'betacomp4D');

    this.muxSignal(cNet,bcomp3_arr,betacomp3D);
    this.muxSignal(cNet,bcomp4_arr,betacomp4D);

    pirelab.getWireComp(cNet,signs1,cnu_decomp1,'');
    pirelab.getWireComp(cNet,signs2,cnu_decomp2,'');
    pirelab.getWireComp(cNet,betacomp3D,cnu_decomp3,'');
    pirelab.getWireComp(cNet,betacomp4D,cnu_decomp4,'');
    pirelab.getWireComp(cNet,valido,cnu_valid,'');


end





