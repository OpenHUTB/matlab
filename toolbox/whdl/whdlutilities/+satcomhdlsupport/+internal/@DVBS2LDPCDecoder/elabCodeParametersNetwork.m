function cpNet=elabCodeParametersNetwork(~,topNet,blockInfo,dataRate)




    ufix1Type=pir_boolean_t();
    ufix8Type=pir_ufixpt_t(8,0);
    oType=pir_ufixpt_t(blockInfo.maxOutWL,0);
    dataType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);


    cpNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CodeParameters',...
    'Inportnames',{'dataIn','startIn','endIn','validIn','numIterIn','outlen'},...
    'InportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type,ufix8Type,oType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'dataOut','validOut','framevalid','reset','softReset','numiter','parind'},...
    'OutportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix8Type,ufix1Type]...
    );



    datai=cpNet.PirInputSignals(1);
    starti=cpNet.PirInputSignals(2);
    endi=cpNet.PirInputSignals(3);
    validi=cpNet.PirInputSignals(4);
    niteri=cpNet.PirInputSignals(5);
    outlen=cpNet.PirInputSignals(6);

    datao=cpNet.PirOutputSignals(1);
    valido=cpNet.PirOutputSignals(2);
    framevalid=cpNet.PirOutputSignals(3);
    reseto=cpNet.PirOutputSignals(4);
    softreset=cpNet.PirOutputSignals(5);
    nitero=cpNet.PirOutputSignals(6);
    parind=cpNet.PirOutputSignals(7);

    if strcmpi(blockInfo.SpecifyInputs,'Input port')
        sof_vld=cpNet.addSignal(ufix1Type,'startValid');
        pirelab.getLogicComp(cpNet,[starti,validi],sof_vld,'and');

        range_iter=cpNet.addSignal(ufix1Type,'rangeIter');
        pirelab.getCompareToValueComp(cpNet,niteri,range_iter,'>',63,'iter range');

        const8=cpNet.addSignal(niteri.Type,'const8');
        pirelab.getConstComp(cpNet,const8,8);

        iteract=cpNet.addSignal(niteri.Type,'iterAct');
        pirelab.getSwitchComp(cpNet,[niteri,const8],iteract,range_iter,'sel','==',0,'Floor','Wrap');

        pirelab.getUnitDelayEnabledComp(cpNet,iteract,nitero,sof_vld,'',8);
    else
        pirelab.getConstComp(cpNet,nitero,blockInfo.NumIterations);
    end


    reset=cpNet.addSignal(ufix1Type,'reset');
    frame_valid=cpNet.addSignal(ufix1Type,'frameValid');
    endind=cpNet.addSignal(ufix1Type,'endInd');
    parityind=cpNet.addSignal(ufix1Type,'parityInd');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','frameController.m'),'r');
    frameController=fread(fid,Inf,'char=>char');
    fclose(fid);

    cpNet.addComponent2(...
    'kind','cgireml',...
    'Name','frameController',...
    'InputSignals',[starti,endi,validi,outlen],...
    'OutputSignals',[reset,frame_valid,endind,parityind],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','frameController',...
    'EMLFileBody',frameController,...
    'EmlParams',{blockInfo.maxOutWL},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    pirelab.getUnitDelayComp(cpNet,reset,reseto,0,'');
    pirelab.getUnitDelayComp(cpNet,datai,datao,0,'');
    pirelab.getUnitDelayComp(cpNet,validi,valido,0,'');
    pirelab.getUnitDelayComp(cpNet,frame_valid,framevalid,0,'');
    pirelab.getUnitDelayComp(cpNet,endind,softreset,0,'');
    pirelab.getUnitDelayComp(cpNet,parityind,parind,0,'');

end