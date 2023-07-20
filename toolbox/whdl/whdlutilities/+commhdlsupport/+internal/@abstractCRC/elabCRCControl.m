function ctlNet=elabCRCControl(~,topNet,blockInfo,inRate)




    ufix1Type=pir_ufixpt_t(1,0);


    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;
    depth=clen/dlen;
    if(clen==dlen)
        cntval=2*clen/dlen-1;
    else
        cntval=clen/dlen-1;
    end
    cntWL=floor(log2(double(cntval)))+1;
    cntType=pir_ufixpt_t(cntWL,0);

    outportnames={'startOut','processMsg','padZero','outputCRC','endOut','validOut','regClr','counter'};
    outporttypes=[ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix1Type,cntType];

    if(clen>dlen)
        outportnames=[outportnames,{'counter_outputCRC'}];
        outporttypes=[outporttypes,cntType];
    end


    ctlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCGenControl',...
    'InportNames',{'startIn','endIn','validIn'},...
    'InportTypes',[ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[inRate,inRate,inRate],...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );


    sofin=ctlNet.PirInputSignals(1);
    eofin=ctlNet.PirInputSignals(2);
    validin=ctlNet.PirInputSignals(3);

    sofout=ctlNet.PirOutputSignals(1);
    processMsg=ctlNet.PirOutputSignals(2);
    padZero=ctlNet.PirOutputSignals(3);
    outputCRC=ctlNet.PirOutputSignals(4);
    eofout=ctlNet.PirOutputSignals(5);
    validout=ctlNet.PirOutputSignals(6);
    regClr=ctlNet.PirOutputSignals(7);
    cntout=ctlNet.PirOutputSignals(8);

    if(clen>dlen)
        cntout_opcrc=ctlNet.PirOutputSignals(9);
    end


    ctype=sofin.Type;
    endOutTemp=ctlNet.addSignal(ctype,'endOutTemp');
    validOutTemp=ctlNet.addSignal(ctype,'validOutTemp');
    validLowFlag=ctlNet.addSignal(ctype,'validLowFlag');
    desc='CRC Generator Control FSM';
    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@abstractCRC','cgireml','CRCControlFSM.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);


    sofindelay=ctlNet.addSignal(ctype,'sofindelay');
    eofindelay=ctlNet.addSignal(ctype,'eofindelay');
    validindelay=ctlNet.addSignal(ctype,'validindelay');
    delayComp=pirelab.getIntDelayComp(ctlNet,sofin,sofindelay,1,'startInReg',0,0);
    delayComp.addComment('startIn buffer');
    delayComp=pirelab.getIntDelayComp(ctlNet,eofin,eofindelay,1,'endInReg',0,0);
    delayComp.addComment('endIn buffer');
    delayComp=pirelab.getIntDelayComp(ctlNet,validin,validindelay,1,'validInReg',0,0);
    delayComp.addComment('validIn buffer');

    inports=[validin,sofin,validindelay,sofindelay,eofindelay];
    if clen>dlen
        outports=[validOutTemp,endOutTemp,validLowFlag,outputCRC,processMsg,padZero,regClr,cntout,cntout_opcrc];
    else
        outports=[validOutTemp,endOutTemp,validLowFlag,outputCRC,processMsg,padZero,regClr,cntout];
    end

    bFSM=ctlNet.addComponent2(...
    'kind','cgireml',...
    'Name','CRCControlFSM',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','CRCControlFSM',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{clen,dlen},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    bFSM.runConcurrencyMaximizer(0);


    delayComp=pirelab.getIntDelayComp(ctlNet,sofin,sofout,depth+1,'dataOut_register',0,0);
    delayComp.addComment('buffer for startOut');

    validLowFlagDelay=ctlNet.addSignal(ctype,'validLowFlagDelay');
    delayComp=pirelab.getIntDelayComp(ctlNet,validLowFlag,validLowFlagDelay,depth+0,'validLowFlag_register',0,0);
    delayComp.addComment('buffer for validLowFlag');
    delayComp=pirelab.getLogicComp(ctlNet,[validOutTemp,validLowFlagDelay],validout,'and');
    delayComp.addComment('drag validOut down when validIn is low in the message processing state');



    delayComp=pirelab.getIntDelayComp(ctlNet,endOutTemp,eofout,depth+0,'dataOut_register',0,0);
    delayComp.addComment('buffer for endOut');

