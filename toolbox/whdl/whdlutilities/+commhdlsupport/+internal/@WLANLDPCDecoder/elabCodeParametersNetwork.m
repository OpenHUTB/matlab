function cpNet=elabCodeParametersNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_boolean_t();
    ufix2Type=pir_ufixpt_t(2,0);
    ufix6Type=pir_ufixpt_t(6,0);
    ufix7Type=pir_ufixpt_t(7,0);
    ufix8Type=pir_ufixpt_t(8,0);
    aIType=pir_ufixpt_t(blockInfo.shiftWL-2,0);%#ok<*NASGU> 

    iType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);
    iVType=pirelab.getPirVectorType(iType,blockInfo.VectorSize);
    uVType=pirelab.getPirVectorType(ufix1Type,blockInfo.VectorSize);


    cpNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CodeParameters',...
    'Inportnames',{'dataIn','startIn','endIn','validIn','blockLen','codeRate','niter'},...
    'InportTypes',[iVType,ufix1Type,ufix1Type,ufix1Type,ufix2Type,ufix2Type,ufix8Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'dataOut','validOut','frameValid','reset','endInd','smDone','niter'},...
    'OutportTypes',[iVType,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix8Type]...
    );



    datai=cpNet.PirInputSignals(1);
    starti=cpNet.PirInputSignals(2);
    endi=cpNet.PirInputSignals(3);
    validi=cpNet.PirInputSignals(4);
    bleni=cpNet.PirInputSignals(5);
    ratei=cpNet.PirInputSignals(6);
    niteri=cpNet.PirInputSignals(7);

    datao=cpNet.PirOutputSignals(1);
    valido=cpNet.PirOutputSignals(2);
    framevalid=cpNet.PirOutputSignals(3);
    reseto=cpNet.PirOutputSignals(4);
    endindo=cpNet.PirOutputSignals(5);
    smdoneo=cpNet.PirOutputSignals(6);
    nitero=cpNet.PirOutputSignals(7);

    if strcmpi(blockInfo.Termination,'Max')&&strcmpi(blockInfo.SpecifyInputs,'Input port')
        range_iter=cpNet.addSignal(ufix1Type,'rangeIter');
        pirelab.getCompareToValueComp(cpNet,niteri,range_iter,'>',63,'iter range');

        const8=cpNet.addSignal(niteri.Type,'const8');
        pirelab.getConstComp(cpNet,const8,8);

        iteract=cpNet.addSignal(niteri.Type,'iterAct');
        pirelab.getSwitchComp(cpNet,[niteri,const8],iteract,range_iter,'sel','==',0,'Floor','Wrap');

        pirelab.getUnitDelayComp(cpNet,iteract,nitero,'',8);
    else
        pirelab.getWireComp(cpNet,niteri,nitero);
    end

    if strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax')
        LUT=[27,54,81,27];
        smsize=cpNet.addSignal(ufix7Type,'smSize');
        pirelab.getDirectLookupComp(cpNet,bleni,smsize,LUT,'subMatrixLUT','','','','',ufix7Type);
    else
        smsize=cpNet.addSignal(ufix6Type,'smSize');
        pirelab.getConstComp(cpNet,smsize,42);
    end


    reset=cpNet.addSignal(ufix1Type,'reset');
    wr_valid=cpNet.addSignal(ufix1Type,'wrValid');
    rd_valid=cpNet.addSignal(ufix1Type,'rdValid');
    frame_valid=cpNet.addSignal(ufix1Type,'frameValid');
    endind=cpNet.addSignal(ufix1Type,'endInd');

    sFlag=strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','frameController.m'),'r');
    frameController=fread(fid,Inf,'char=>char');
    fclose(fid);

    cpNet.addComponent2(...
    'kind','cgireml',...
    'Name','frameController',...
    'InputSignals',[starti,endi,validi,smsize],...
    'OutputSignals',[reset,wr_valid,rd_valid,frame_valid,endind],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','frameController',...
    'EMLFileBody',frameController,...
    'EmlParams',{blockInfo.VectorSize,sFlag},...
    'EMLFlag_TreatInputIntsAsFixpt',true);


    if blockInfo.VectorSize==8
        aWL=8;
        wr_data=cpNet.addSignal(datai.Type,'wrData');
        wr_en=cpNet.addSignal(uVType,'wrEnb');
        coldata=cpNet.addSignal(datai.Type,'colData');
        wr_addr=cpNet.addSignal(ufix8Type,'wrAddr');
        rd_addr=cpNet.addSignal(ufix8Type,'rdAddr');
        rdvalid=cpNet.addSignal(ufix1Type,'rdValid');
        smdone=cpNet.addSignal(ufix1Type,'smDone');

        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','writeController.m'),'r');
        writeController=fread(fid,Inf,'char=>char');
        fclose(fid);

        cpNet.addComponent2(...
        'kind','cgireml',...
        'Name','writeController',...
        'InputSignals',[datai,reset,wr_valid,rd_valid,smsize],...
        'OutputSignals',[wr_data,wr_addr,wr_en,rd_addr,rdvalid,smdone],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','writeController',...
        'EMLFileBody',writeController,...
        'EmlParams',{sFlag,aWL,blockInfo.shiftWL-2},...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        wrdata_array=this.demuxSignal(cpNet,wr_data,'wrdata_array');
        wren_array=this.demuxSignal(cpNet,wr_en,'wren_array');
        for idx=1:8
            data_array(idx)=cpNet.addSignal(iType,['data_array_',num2str(idx)]);%#ok<*AGROW>
            pirelab.getSimpleDualPortRamComp(cpNet,[wrdata_array(idx),wr_addr,wren_array(idx),rd_addr],data_array(idx),'Variable Node RAM',1,-1,[],'','',blockInfo.ramAttr_dist);
        end
        this.muxSignal(cpNet,data_array,coldata);

        pirelab.getUnitDelayComp(cpNet,coldata,datao,0,'');
        pirelab.getUnitDelayComp(cpNet,rdvalid,valido,0,'');

        frame_valid_tmp=cpNet.addSignal(ufix1Type,'fValidTmp');
        pirelab.getIntDelayComp(cpNet,frame_valid,frame_valid_tmp,4,0);

        pirelab.getLogicComp(cpNet,[frame_valid_tmp,valido],framevalid,'or');
        pirelab.getIntDelayComp(cpNet,smdone,smdoneo,2,0,'');
    else
        pirelab.getUnitDelayComp(cpNet,datai,datao,0,'');
        pirelab.getUnitDelayComp(cpNet,rd_valid,valido,0,'');
        pirelab.getUnitDelayComp(cpNet,frame_valid,framevalid,0,'');

        pirelab.getConstComp(cpNet,smdoneo,0);
    end

    pirelab.getIntDelayComp(cpNet,endind,endindo,3,0);
    pirelab.getUnitDelayComp(cpNet,reset,reseto,0,'');
end
