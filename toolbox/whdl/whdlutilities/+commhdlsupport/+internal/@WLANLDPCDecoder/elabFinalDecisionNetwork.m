function fdNet=elabFinalDecisionNetwork(this,topNet,blockInfo,dataRate)






    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    cntType=pir_ufixpt_t(blockInfo.shiftWL-2,0);
    sType=pir_ufixpt_t(blockInfo.shiftWL,0);
    fType=pirelab.getPirVectorType(sType,blockInfo.finalVec);

    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);

    dType=pir_ufixpt_t(1,0);
    decType=pirelab.getPirVectorType(dType,blockInfo.memDepth);


    fdNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FinalDecision',...
    'Inportnames',{'data','iterdone','smsize','rate','fin_shift','reset'},...
    'InportTypes',[alphaVType,ufix1Type,sType,ufix2Type,fType,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'decbits','start','valid','shift'},...
    'OutportTypes',[decType,ufix1Type,ufix1Type,sType]...
    );



    data=fdNet.PirInputSignals(1);
    iterdone=fdNet.PirInputSignals(2);
    smsize=fdNet.PirInputSignals(3);
    rate=fdNet.PirInputSignals(4);
    finalV=fdNet.PirInputSignals(5);
    reset=fdNet.PirInputSignals(6);

    decbits=fdNet.PirOutputSignals(1);
    startout=fdNet.PirOutputSignals(2);
    validout=fdNet.PirOutputSignals(3);
    shift=fdNet.PirOutputSignals(4);


    datao=fdNet.addSignal(decbits.Type,'data');
    starto=fdNet.addSignal(ufix1Type,'start_out');
    valido=fdNet.addSignal(ufix1Type,'valid_out');
    counto=fdNet.addSignal(cntType,'count');
    shifto=fdNet.addSignal(shift.Type,'shift');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','finaldecision.m'),'r');
    finaldecision=fread(fid,Inf,'char=>char');
    fclose(fid);

    sFlag=strcmpi(blockInfo.Standard,'IEEE 802.11 n/ac/ax');
    scalarFlag=blockInfo.VectorSize==1;
    mem=blockInfo.memDepth;

    fdNet.addComponent2(...
    'kind','cgireml',...
    'Name','finaldecision',...
    'InputSignals',[data,iterdone,rate,smsize,reset],...
    'OutputSignals',[datao,starto,valido,counto],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','finaldecision',...
    'EMLFileBody',finaldecision,...
    'EmlParams',{sFlag,scalarFlag,mem},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    shiftarray=this.demuxSignal(fdNet,finalV,'demux');

    x=[];
    for i=1:blockInfo.finalVec
        x=[x,shiftarray(i)];%#ok<*AGROW>
    end

    x=[shiftarray(1),x];

    pirelab.getMultiPortSwitchComp(fdNet,[counto,x],shifto,1,1,'Floor','Wrap');

    pirelab.getUnitDelayComp(fdNet,datao,decbits,'dataOut',0);
    pirelab.getUnitDelayComp(fdNet,starto,startout,'startOut',0);
    pirelab.getUnitDelayComp(fdNet,valido,validout,'validOut',0);
    pirelab.getUnitDelayComp(fdNet,shifto,shift,'shift_reg',0);

end
