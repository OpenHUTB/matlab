function dcNet=elabDecoderCoreNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_boolean_t;
    ufix2Type=pir_ufixpt_t(2,0);
    ufix4Type=pir_ufixpt_t(4,0);
    ufix8Type=pir_ufixpt_t(8,0);
    colType=pir_ufixpt_t(blockInfo.cWL,0);
    cType=pir_ufixpt_t(blockInfo.vaddrWL,0);
    layType=pir_ufixpt_t(blockInfo.layWL,0);
    vType=pir_ufixpt_t(blockInfo.vWL,0);
    oType=pir_ufixpt_t(blockInfo.outWL,0);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);

    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    eType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);

    aVType=pirelab.getPirVectorType(aType,blockInfo.vectorSize);
    dVType=pirelab.getPirVectorType(ufix1Type,blockInfo.vectorSize);


    dcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DecoderCore',...
    'Inportnames',{'dataIn','validIn','frameValid','reset','endInd','numIter','blockLen','codeRate'},...
    'InportTypes',[aVType,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix8Type,ufix2Type,ufix2Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'dataOut','startOut','endOut','validOut','iterOut','parCheck'},...
    'OutportTypes',[dVType,ufix1Type,ufix1Type,ufix1Type,ufix8Type,ufix1Type]...
    );



    data=dcNet.PirInputSignals(1);
    valid=dcNet.PirInputSignals(2);
    framevalid=dcNet.PirInputSignals(3);
    reset=dcNet.PirInputSignals(4);
    endind=dcNet.PirInputSignals(5);
    numiter=dcNet.PirInputSignals(6);
    blocklen=dcNet.PirInputSignals(7);
    coderate=dcNet.PirInputSignals(8);

    dataout=dcNet.PirOutputSignals(1);
    startout=dcNet.PirOutputSignals(2);
    endout=dcNet.PirOutputSignals(3);
    validout=dcNet.PirOutputSignals(4);
    actiter=dcNet.PirOutputSignals(5);
    parcheck=dcNet.PirOutputSignals(6);

    gamma=dcNet.addSignal(alphaVType,'gamma');
    gvalid=dcNet.addSignal(valid.Type,'gValid');
    gaddr=dcNet.addSignal(colType,'gAddr');
    gwrenable=dcNet.addSignal(eType,'gWrEnable');

    gvalid_neg=dcNet.addSignal(ufix1Type,'gValidNeg');
    gvalid_reg=dcNet.addSignal(ufix1Type,'gValidReg');

    pirelab.getLogicComp(dcNet,gvalid,gvalid_neg,'not');
    pirelab.getUnitDelayComp(dcNet,gvalid,gvalid_reg,'',0);

    layerdone=dcNet.addSignal(ufix1Type,'layerDone');
    pirelab.getLogicComp(dcNet,[gvalid_neg,gvalid_reg],layerdone,'and');

    endind_reg=dcNet.addSignal(ufix1Type,'endIndReg');
    endind_neg=dcNet.addSignal(ufix1Type,'endIndNeg');
    pirelab.getUnitDelayComp(dcNet,endind,endind_reg,'',0);
    pirelab.getLogicComp(dcNet,endind_reg,endind_neg,'not');

    softreset=dcNet.addSignal(ufix1Type,'softReset');
    pirelab.getLogicComp(dcNet,[endind_neg,endind],softreset,'and');

    termpass=dcNet.addSignal(ufix1Type,'termPass');
    termpass_reg=dcNet.addSignal(ufix1Type,'termPassReg');
    if blockInfo.earlyFlag
        pirelab.getWireComp(dcNet,termpass,termpass_reg,'');
    else
        pirelab.getConstComp(dcNet,termpass_reg,0);
    end

    wr_data=dcNet.addSignal(alphaVType,'wrData');
    wr_enb=dcNet.addSignal(eType,'wrEnb');
    wr_addr=dcNet.addSignal(colType,'wrAddr');
    rd_valid=dcNet.addSignal(ufix1Type,'rdValid');
    iterdone=dcNet.addSignal(ufix1Type,'iterDone');
    iterind=dcNet.addSignal(ufix1Type,'iterInd');
    betaread=dcNet.addSignal(ufix1Type,'betaRead');
    countidx=dcNet.addSignal(cType,'countIdx');
    countlayer=dcNet.addSignal(layType,'countLayer');
    validcount=dcNet.addSignal(cType,'validCount');
    iterout=dcNet.addSignal(actiter.Type,'iterOut');
    rdout_addr=dcNet.addSignal(colType,'rdOutAddr');
    rdout_valid=dcNet.addSignal(ufix1Type,'rdOutValid');
    shiftsel=dcNet.addSignal(ufix2Type,'shiftSel');

    colval=dcNet.addSignal(colType,'colVal');
    shift=dcNet.addSignal(vType,'shiftVal');
    rdenb=dcNet.addSignal(eType,'rdEnable');
    wrenb=dcNet.addSignal(eType,'wrEnable');
    erasecol=dcNet.addSignal(ufix1Type,'eraseCol');

    sFlag=blockInfo.scalarFlag;
    eFlag=blockInfo.earlyFlag;

    rdenb_reg=dcNet.addSignal(eType,'rdEnbReg');



    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','iterationControllerBase.m'),'r');
        iterationControllerBase=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','iterationControllerBase',...
        'InputSignals',[data,valid,framevalid,reset,softreset,gamma,gvalid,gaddr,gwrenable,layerdone,numiter,termpass_reg],...
        'OutputSignals',[wr_data,wr_addr,wr_enb,rd_valid,countidx,iterdone,betaread,countlayer,validcount,rdout_addr,rdout_valid,iterout,shiftsel],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','iterationControllerBase',...
        'EMLFileBody',iterationControllerBase,...
        'EmlParams',{sFlag,eFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);



        clNet=this.elabCheckMatrixLUTNetwork(dcNet,blockInfo,dataRate);
        clNet.addComment('Check Matrix LUT');
        pirelab.instantiateNetwork(dcNet,clNet,[blocklen,coderate,countlayer,validcount],...
        [colval,shift,rdenb,wrenb],'Check Matrix LUT');

        pirelab.getIntDelayComp(dcNet,rdenb,rdenb_reg,2,'rdenb',0);

    else
        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','iterationControllerAr4ja.m'),'r');
        iterationControllerAr4ja=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','iterationControllerAr4ja',...
        'InputSignals',[data,valid,framevalid,reset,softreset,blocklen,coderate,gamma,gvalid,gaddr,gwrenable,layerdone,numiter,termpass_reg],...
        'OutputSignals',[wr_data,wr_addr,wr_enb,rd_valid,countidx,iterdone,betaread,countlayer,validcount,rdout_addr,rdout_valid,iterout,shiftsel,iterind],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','iterationControllerAr4ja',...
        'EMLFileBody',iterationControllerAr4ja,...
        'EmlParams',{sFlag,eFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);



        clNet=this.elabCheckMatrixLUTNetwork(dcNet,blockInfo,dataRate);
        clNet.addComment('Check Matrix LUT');
        pirelab.instantiateNetwork(dcNet,clNet,[blocklen,coderate,countlayer,validcount],...
        [colval,shift,rdenb,erasecol],'Check Matrix LUT');

        iterind_neg=dcNet.addSignal(ufix1Type,'iterIndNeg');
        erasecol_reg=dcNet.addSignal(ufix1Type,'eraseColReg');

        pirelab.getLogicComp(dcNet,iterind,iterind_neg,'not');
        pirelab.getUnitDelayComp(dcNet,erasecol,erasecol_reg,'eraseCol',0);

        eind=dcNet.addSignal(ufix1Type,'eraseInd');
        pirelab.getLogicComp(dcNet,[erasecol_reg,iterind_neg],eind,'and');

        pirelab.getIntDelayComp(dcNet,rdenb,rdenb_reg,1,'rdenb',0);
    end

    intreset=dcNet.addSignal(ufix1Type,'intReset');
    pirelab.getLogicComp(dcNet,[softreset,reset],intreset,'or');

    rd_valid_reg=dcNet.addSignal(ufix1Type,'rdValidReg');
    pirelab.getIntDelayComp(dcNet,rd_valid,rd_valid_reg,2,'rdvalid',0);

    zerodata=dcNet.addSignal(alphaVType,'zeroData');
    pirelab.getConstComp(dcNet,zerodata,0);

    enbdata=dcNet.addSignal(eType,'enbData');
    pirelab.getConstComp(dcNet,enbdata,1);


    wrdata_ram=dcNet.addSignal(alphaVType,'wrDataRAM');
    wrenb_ram=dcNet.addSignal(eType,'wrEnbRAM');
    wraddr_ram=dcNet.addSignal(colType,'wrAddrRAM');
    rdaddr_ram=dcNet.addSignal(colType,'rdAddrRAM');
    addr_reg=dcNet.addSignal(colType,'rdAddrReg');

    pirelab.getSwitchComp(dcNet,[rdout_addr,colval],rdaddr_ram,iterdone,'switchComp','==',1);
    pirelab.getUnitDelayComp(dcNet,rdaddr_ram,addr_reg,'addrReg',0);

    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        pirelab.getWireComp(dcNet,wr_data,wrdata_ram,'');
        pirelab.getWireComp(dcNet,wr_enb,wrenb_ram,'');
        pirelab.getWireComp(dcNet,wr_addr,wraddr_ram,'');
    else
        pirelab.getSwitchComp(dcNet,[zerodata,wr_data],wrdata_ram,eind,'switchComp','==',1);
        pirelab.getSwitchComp(dcNet,[enbdata,wr_enb],wrenb_ram,eind,'switchComp','==',1);
        pirelab.getSwitchComp(dcNet,[addr_reg,wr_addr],wraddr_ram,eind,'switchComp','==',1);
    end

    wrdata_array=this.demuxSignal(dcNet,wrdata_ram,'wrdata_array');
    wren_array=this.demuxSignal(dcNet,wrenb_ram,'wren_array');
    coldata=dcNet.addSignal(alphaVType,'colData');


    for idx=1:blockInfo.memDepth
        data_array(idx)=dcNet.addSignal(aType,['data_array_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getSimpleDualPortRamComp(dcNet,[wrdata_array(idx),wraddr_ram,wren_array(idx),rdaddr_ram],data_array(idx),'Variable Node RAM',1,-1,[],'','',blockInfo.vnuRAM);
    end
    this.muxSignal(dcNet,data_array,coldata);

    shift_reg=dcNet.addSignal(vType,'shiftValReg');
    pirelab.getIntDelayComp(dcNet,shift,shift_reg,1,'',0);

    gdata=dcNet.addSignal(alphaVType,'gData');
    grdenb=dcNet.addSignal(eType,'gRdEnb');


    edata=dcNet.addSignal(alphaVType,'eraseData');
    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        pirelab.getWireComp(dcNet,coldata,edata,'');
    else
        pirelab.getSwitchComp(dcNet,[zerodata,coldata],edata,eind,'switchComp','==',1);
    end



    mNet=this.elabMetricCalculatorNetwork(dcNet,blockInfo,dataRate);
    mNet.addComment('Metric Calculator');
    pirelab.instantiateNetwork(dcNet,mNet,[edata,rd_valid_reg,shift_reg,countidx,betaread,rdenb_reg,countlayer,intreset,shiftsel],...
    [gamma,gvalid,gdata,grdenb],'Metric Calculator');

    wr_addr_v=dcNet.addSignal(cType,'wrAddrV');
    rd_addr_v=dcNet.addSignal(cType,'rdAddrV');


    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','varAddressGeneration.m'),'r');
    varAddressGeneration=fread(fid,Inf,'char=>char');
    fclose(fid);

    dcNet.addComponent2(...
    'kind','cgireml',...
    'Name','varAddressGeneration',...
    'InputSignals',[rd_valid_reg,countidx,gvalid,intreset],...
    'OutputSignals',[wr_addr_v,rd_addr_v],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','varAddressGeneration',...
    'EMLFileBody',varAddressGeneration,...
    'EmlParams',{blockInfo.vaddrWL},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    colval_reg=dcNet.addSignal(colType,'colValReg');
    pirelab.getIntDelayComp(dcNet,colval,colval_reg,1,'',0);


    pirelab.getSimpleDualPortRamComp(dcNet,[colval_reg,wr_addr_v,rd_valid_reg,rd_addr_v],gaddr,'Variable column RAM',1,-1,[],'','','');
    nrow=dcNet.addSignal(layType,'nRow');

    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        wrenb_reg=dcNet.addSignal(eType,'wrEnbReg');
        pirelab.getIntDelayComp(dcNet,wrenb,wrenb_reg,1,'',0);


        pirelab.getSimpleDualPortRamComp(dcNet,[wrenb_reg,wr_addr_v,rd_valid_reg,rd_addr_v],gwrenable,'Variable column RAM',blockInfo.memDepth,-1,[],'','','');
        pirelab.getConstComp(dcNet,nrow,15);
    else
        pirelab.getIntDelayComp(dcNet,grdenb,gwrenable,1,'',0);
        idx_con=dcNet.addSignal(ufix4Type,'indexConcat');
        pirelab.getBitConcatComp(dcNet,[blocklen,coderate],idx_con,'');
        pirelab.getDirectLookupComp(dcNet,idx_con,nrow,blockInfo.nRowLUT,'rowLUT','','','','',layType);
    end

    grdenb_reg=dcNet.addSignal(eType,'gRdEnableReg');
    pirelab.getIntDelayComp(dcNet,grdenb,grdenb_reg,1,'rdEnb',0);

    gdata_reg=dcNet.addSignal(alphaVType,'gDataReg');
    pirelab.getIntDelayComp(dcNet,gdata,gdata_reg,1,'gData',0);

    if blockInfo.earlyFlag||blockInfo.ParityCheckStatus


        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','finalParityChecks.m'),'r');
        finalParityChecks=fread(fid,Inf,'char=>char');
        fclose(fid);

        dcNet.addComponent2(...
        'kind','cgireml',...
        'Name','finalParityChecks',...
        'InputSignals',[intreset,gdata_reg,gvalid,countidx,grdenb_reg,nrow],...
        'OutputSignals',termpass,...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','finalParityChecks',...
        'EMLFileBody',finalParityChecks,...
        'EmlParams',{blockInfo.memDepth,blockInfo.cWL,blockInfo.layWL},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    else
        pirelab.getConstComp(dcNet,termpass,0);
    end


    outlen=dcNet.addSignal(oType,'outLen');
    pirelab.getDirectLookupComp(dcNet,blocklen,outlen,blockInfo.outLenLUT,'lenLUT','','','','',oType);


    hard_data=dcNet.addSignal(eType,'hardData');
    pirelab.getCompareToValueComp(dcNet,coldata,hard_data,'<=',0,'compare',1);

    rdout_valid_reg=dcNet.addSignal(ufix1Type,'rdValidReg');
    pirelab.getIntDelayComp(dcNet,rdout_valid,rdout_valid_reg,1,'',0);

    datao=dcNet.addSignal(dataout.Type,'dataO');
    starto=dcNet.addSignal(ufix1Type,'startO');
    endo=dcNet.addSignal(ufix1Type,'endO');
    valido=dcNet.addSignal(ufix1Type,'validO');



    fONet=this.elabFinalOutputNetwork(dcNet,blockInfo,dataRate);
    fONet.addComment('Final Output');
    pirelab.instantiateNetwork(dcNet,fONet,[intreset,iterdone,rdout_valid_reg,hard_data,outlen,shiftsel],...
    [datao,starto,endo,valido],'Final Output');

    constdata=dcNet.addSignal(dataout.Type,'constData');
    pirelab.getConstComp(dcNet,constdata,0);

    const1=dcNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(dcNet,const1,0);

    datao_tmp=dcNet.addSignal(dataout.Type,'dataTmp');
    starto_tmp=dcNet.addSignal(startout.Type,'startTmp');
    endo_tmp=dcNet.addSignal(endout.Type,'endTmp');
    valido_tmp=dcNet.addSignal(validout.Type,'validTmp');
    iterout_tmp=dcNet.addSignal(actiter.Type,'iterTmp');
    termpass_tmp=dcNet.addSignal(termpass.Type,'parCheckTmp');

    pirelab.getSwitchComp(dcNet,[datao,constdata],datao_tmp,valido,'data sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[starto,const1],starto_tmp,valido,'start sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[endo,const1],endo_tmp,valido,'end sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[valido,const1],valido_tmp,valido,'valid sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[iterout,const1],iterout_tmp,valido,'iter sel','==',1,'Floor','Wrap');
    pirelab.getSwitchComp(dcNet,[termpass,const1],termpass_tmp,valido,'parcheck sel','==',1,'Floor','Wrap');

    pirelab.getUnitDelayComp(dcNet,datao_tmp,dataout,'dataOut',0);
    pirelab.getUnitDelayComp(dcNet,starto_tmp,startout,'startOut',0);
    pirelab.getUnitDelayComp(dcNet,endo_tmp,endout,'endOut',0);
    pirelab.getUnitDelayComp(dcNet,valido_tmp,validout,'validOut',0);
    pirelab.getUnitDelayComp(dcNet,termpass_tmp,parcheck,'parCheck',0);
    pirelab.getUnitDelayComp(dcNet,iterout_tmp,actiter,'actIter',0);
end



