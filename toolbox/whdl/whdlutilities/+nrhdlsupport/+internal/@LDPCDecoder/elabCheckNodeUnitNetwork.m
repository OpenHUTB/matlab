function cNet=elabCheckNodeUnitNetwork(this,topNet,blockInfo,dataRate)



    ufix1Type=pir_ufixpt_t(1,0);
    ufix5Type=pir_ufixpt_t(5,0);
    sType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);

    mType=pir_ufixpt_t(blockInfo.minWL,blockInfo.alphaFL);
    minType=pirelab.getPirVectorType(mType,blockInfo.memDepth);

    m1Type=pir_ufixpt_t(blockInfo.minWL+1,blockInfo.alphaFL);
    min1Type=pirelab.getPirVectorType(m1Type,blockInfo.memDepth);

    iType=pir_ufixpt_t(5,0);
    idxType=pirelab.getPirVectorType(iType,blockInfo.memDepth);

    bc1Type=pir_ufixpt_t(25,0);
    bc2Type=pir_ufixpt_t(2*blockInfo.minWL,0);

    cType=pir_ufixpt_t(19,0);
    scType=pirelab.getPirVectorType(cType,blockInfo.memDepth);

    vType1=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);
    v1Type=pirelab.getPirVectorType(vType1,blockInfo.memDepth);

    bcV1Type=pirelab.getPirVectorType(bc1Type,blockInfo.memDepth);
    bcV2Type=pirelab.getPirVectorType(bc2Type,blockInfo.memDepth);


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CheckNodeUnit',...
    'Inportnames',{'data','valid','count','reset'},...
    'InportTypes',[v1Type,ufix1Type,ufix5Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'cnuDecomp1','cnuDecomp2','cnuvalid'},...
    'OutportTypes',[bcV1Type,bcV2Type,ufix1Type]...
    );



    data=cNet.PirInputSignals(1);
    valid=cNet.PirInputSignals(2);
    count=cNet.PirInputSignals(3);
    reset=cNet.PirInputSignals(4);

    cnu_decomp1=cNet.PirOutputSignals(1);
    cnu_decomp2=cNet.PirOutputSignals(2);
    cnu_valid=cNet.PirOutputSignals(3);


    data_reg=cNet.addSignal(data.Type,'dataReg');
    dataabs=cNet.addSignal(min1Type,'dataAbs');
    valid_reg=cNet.addSignal(valid.Type,'validReg');
    count_reg=cNet.addSignal(count.Type,'countReg');
    reset_reg=cNet.addSignal(reset.Type,'resetReg');

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

    pirelab.getAbsComp(cNet,data_reg,dataabs);

    counti=cNet.addSignal(count.Type,'countU');
    min1=cNet.addSignal(min1Type,'minVal1');
    min2=cNet.addSignal(min1Type,'minVal2');
    minindex=cNet.addSignal(idxType,'minindex');
    signs=cNet.addSignal(scType,'signs');
    prodsign=cNet.addSignal(sType,'prodsign');
    valido=cNet.addSignal(ufix1Type,'validD');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','minCalculation.m'),'r');
    minCalculation=fread(fid,Inf,'char=>char');
    fclose(fid);

    maxVal=(2^(blockInfo.betaWL-1)-1);
    mem=blockInfo.memDepth;
    ul=blockInfo.betaWL;
    bFL=-blockInfo.alphaFL;

    const1=cNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(cNet,const1,1);

    pirelab.getAddComp(cNet,[count_reg,const1],counti,'Floor','Wrap','AddComp');

    cNet.addComponent2(...
    'kind','cgireml',...
    'Name','minCalculation',...
    'InputSignals',[data_reg,valid_reg,counti,extreset,dataabs],...
    'OutputSignals',[min1,min2,minindex,signs,prodsign,valido],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','minCalculation',...
    'EMLFileBody',minCalculation,...
    'EmlParams',{maxVal,mem,ul,bFL},...
    'EMLFlag_TreatInputIntsAsFixpt',true);



    psign_arr=this.demuxSignal(cNet,prodsign,'psign_array');
    sign_arr=this.demuxSignal(cNet,signs,'signs_array');
    minindex_arr=this.demuxSignal(cNet,minindex,'minindx_array');



    min1dtc=cNet.addSignal(minType,'min1_DTC');
    min2dtc=cNet.addSignal(minType,'min2_DTC');

    pirelab.getDTCComp(cNet,min1,min1dtc,'Floor','Saturate');
    pirelab.getDTCComp(cNet,min2,min2dtc,'Floor','Saturate');

    min1_arr=this.demuxSignal(cNet,min1dtc,'min1_array');
    min2_arr=this.demuxSignal(cNet,min2dtc,'min2_array');


    for idx=1:blockInfo.memDepth
        bcomp1_arr(idx)=cNet.addSignal(bc1Type,['betacomp1_arr_',num2str(idx)]);%#ok<*AGROW>
        bcomp2_arr(idx)=cNet.addSignal(bc2Type,['betacomp2_arr_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getBitConcatComp(cNet,[psign_arr(idx),minindex_arr(idx),sign_arr(idx)],bcomp1_arr(idx),'bitConcat1');
        pirelab.getBitConcatComp(cNet,[min1_arr(idx),min2_arr(idx)],bcomp2_arr(idx),'bitConcat2');
    end

    betacomp1D=cNet.addSignal(cnu_decomp1.Type,'betacomp1D');
    betacomp2D=cNet.addSignal(cnu_decomp2.Type,'betacomp2D');

    this.muxSignal(cNet,bcomp1_arr,betacomp1D);
    this.muxSignal(cNet,bcomp2_arr,betacomp2D);

    pirelab.getWireComp(cNet,betacomp1D,cnu_decomp1,'');
    pirelab.getWireComp(cNet,betacomp2D,cnu_decomp2,'');
    pirelab.getWireComp(cNet,valido,cnu_valid,'');


end



