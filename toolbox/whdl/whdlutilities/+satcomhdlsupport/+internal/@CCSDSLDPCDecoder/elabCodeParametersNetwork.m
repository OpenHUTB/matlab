function cpNet=elabCodeParametersNetwork(this,topNet,blockInfo,dataRate)



    ufix1Type=pir_boolean_t;
    dType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);
    dVType=pirelab.getPirVectorType(dType,blockInfo.vectorSize);


    cpNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CodeParameters',...
    'Inportnames',{'dataIn','startIn','endIn','validIn','nextFrame'},...
    'InportTypes',[dVType,ufix1Type,ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'dataOut','validOut','frameValid','reset','endInd'},...
    'OutportTypes',[dVType,ufix1Type,ufix1Type,ufix1Type,ufix1Type]...
    );



    datai=cpNet.PirInputSignals(1);
    starti=cpNet.PirInputSignals(2);
    endi=cpNet.PirInputSignals(3);
    validi=cpNet.PirInputSignals(4);
    nframe=cpNet.PirInputSignals(5);

    dataout=cpNet.PirOutputSignals(1);
    validout=cpNet.PirOutputSignals(2);
    framevalid=cpNet.PirOutputSignals(3);
    reset=cpNet.PirOutputSignals(4);
    endind=cpNet.PirOutputSignals(5);

    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')&&~blockInfo.scalarFlag

        reseto=cpNet.addSignal(ufix1Type,'reset');
        resettmp=cpNet.addSignal(ufix1Type,'resetTmp');
        pirelab.getLogicComp(cpNet,[starti,validi],resettmp,'and');
        pirelab.getLogicComp(cpNet,[resettmp,nframe],reseto,'or');

        const0=cpNet.addSignal(ufix1Type,'const0');
        const0reg=cpNet.addSignal(ufix1Type,'const0Reg');

        const1=cpNet.addSignal(ufix1Type,'const1');
        const1reg=cpNet.addSignal(ufix1Type,'const1Reg');

        pirelab.getConstComp(cpNet,const0,0);
        pirelab.getUnitDelayComp(cpNet,const0,const0reg,'',0);

        pirelab.getConstComp(cpNet,const1,1);
        pirelab.getUnitDelayComp(cpNet,const1,const1reg,'',1);

        end_tmp=cpNet.addSignal(ufix1Type,'endTmp');
        pirelab.getSwitchComp(cpNet,[endi,const0reg],end_tmp,reseto,'sel','==',0,'Floor','Wrap');

        data_delay=cpNet.addSignal(datai.Type,'dataDelay');
        pirelab.getIntDelayComp(cpNet,datai,data_delay,2,'datai',0);

        start_delay=cpNet.addSignal(ufix1Type,'startDelay');
        pirelab.getIntDelayComp(cpNet,starti,start_delay,2,'starti',0);

        end_delay=cpNet.addSignal(ufix1Type,'endDelay');
        pirelab.getIntDelayEnabledResettableComp(cpNet,end_tmp,end_delay,const1reg,reseto,2,'endi',0,'','','');

        valid_delay=cpNet.addSignal(ufix1Type,'validDelay');
        pirelab.getIntDelayComp(cpNet,validi,valid_delay,2,'validi',0);




        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','frameControllerBase.m'),'r');
        frameControllerBase=fread(fid,Inf,'char=>char');
        fclose(fid);

        datamux=cpNet.addSignal(datai.Type,'dataMux');
        starto=cpNet.addSignal(ufix1Type,'startO');
        endo=cpNet.addSignal(ufix1Type,'endO');
        valido=cpNet.addSignal(ufix1Type,'validO');
        validframe=cpNet.addSignal(ufix1Type,'validFrame');

        cpNet.addComponent2(...
        'kind','cgireml',...
        'Name','frameControllerBase',...
        'InputSignals',[reseto,data_delay,start_delay,end_delay,valid_delay],...
        'OutputSignals',[datamux,starto,endo,valido],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','frameControllerBase',...
        'EMLFileBody',frameControllerBase,...
        'EMLFlag_TreatInputIntsAsFixpt',true);




        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','writeController.m'),'r');
        writeController=fread(fid,Inf,'char=>char');
        fclose(fid);

        data_out=cpNet.addSignal(datai.Type,'dataOutReg');
        valid_out=cpNet.addSignal(ufix1Type,'validOutReg');
        fvalid_out=cpNet.addSignal(ufix1Type,'fValidOut');
        endind_out=cpNet.addSignal(ufix1Type,'endIndOut');

        cpNet.addComponent2(...
        'kind','cgireml',...
        'Name','writeController',...
        'InputSignals',[reseto,datamux,starto,endo,valido],...
        'OutputSignals',[data_out,valid_out,fvalid_out,endind_out],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','writeController',...
        'EMLFileBody',writeController,...
        'EMLFlag_TreatInputIntsAsFixpt',true);

    else


        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','frameController.m'),'r');
        frameController=fread(fid,Inf,'char=>char');
        fclose(fid);

        reseto=cpNet.addSignal(ufix1Type,'resetO');
        data_out=cpNet.addSignal(datai.Type,'dataOutReg');
        valid_out=cpNet.addSignal(ufix1Type,'validOutReg');
        fvalid_out=cpNet.addSignal(ufix1Type,'fValidOut');
        endind_out=cpNet.addSignal(ufix1Type,'endIndOut');

        cpNet.addComponent2(...
        'kind','cgireml',...
        'Name','frameController',...
        'InputSignals',[datai,starti,endi,validi],...
        'OutputSignals',[reseto,data_out,valid_out,fvalid_out,endind_out],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','frameController',...
        'EMLFileBody',frameController,...
        'EmlParams',{blockInfo.vectorSize},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end
    pirelab.getUnitDelayComp(cpNet,data_out,dataout,'',0);
    pirelab.getUnitDelayComp(cpNet,valid_out,validout,'',0);
    pirelab.getUnitDelayComp(cpNet,fvalid_out,framevalid,'',0);
    pirelab.getUnitDelayComp(cpNet,reseto,reset,'',0);
    pirelab.getUnitDelayComp(cpNet,endind_out,endind,'',0);
end


