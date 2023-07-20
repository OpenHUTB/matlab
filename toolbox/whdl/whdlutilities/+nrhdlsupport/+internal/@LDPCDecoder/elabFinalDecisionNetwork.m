function fdNet=elabFinalDecisionNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    cntType=pir_ufixpt_t(5,0);
    vType=pir_ufixpt_t(9,0);

    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    aVType=pirelab.getPirVectorType(aType,384);
    sVType=pirelab.getPirVectorType(vType,22);

    dType=pir_ufixpt_t(1,0);
    decType=pirelab.getPirVectorType(dType,384);


    fdNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FinalDecision',...
    'Inportnames',{'data','iterdone','liftsize','bgn','fin_shift','reset'},...
    'InportTypes',[aVType,ufix1Type,vType,ufix1Type,sVType,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'decbits','start','end','valid','shift'},...
    'OutportTypes',[decType,ufix1Type,ufix1Type,ufix1Type,vType]...
    );



    data=fdNet.PirInputSignals(1);
    iterdone=fdNet.PirInputSignals(2);
    liftsize=fdNet.PirInputSignals(3);
    bgn=fdNet.PirInputSignals(4);
    finalV=fdNet.PirInputSignals(5);
    reset=fdNet.PirInputSignals(6);

    decbits=fdNet.PirOutputSignals(1);
    startout=fdNet.PirOutputSignals(2);
    endout=fdNet.PirOutputSignals(3);
    validout=fdNet.PirOutputSignals(4);
    shift=fdNet.PirOutputSignals(5);


    datao=fdNet.addSignal(decbits.Type,'data');
    starto=fdNet.addSignal(ufix1Type,'start_out');
    endo=fdNet.addSignal(ufix1Type,'end_out');
    valido=fdNet.addSignal(ufix1Type,'valid_out');
    counto=fdNet.addSignal(cntType,'count');
    shifto=fdNet.addSignal(shift.Type,'shift');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','finaldecision.m'),'r');
    finaldecision=fread(fid,Inf,'char=>char');
    fclose(fid);

    vecSize=blockInfo.VectorSize;

    fdNet.addComponent2(...
    'kind','cgireml',...
    'Name','finaldecision',...
    'InputSignals',[data,iterdone,bgn,liftsize,reset],...
    'OutputSignals',[datao,starto,endo,valido,counto],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','finaldecision',...
    'EMLFileBody',finaldecision,...
    'EmlParams',{vecSize},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    shiftarray=demuxSignal(fdNet,finalV,'demux');

    x=[];
    for i=1:22
        x=[x,shiftarray(i)];%#ok<*AGROW>
    end

    x=[shiftarray(1),x];

    pirelab.getMultiPortSwitchComp(fdNet,[counto,x],shifto,1,1,'Floor','Wrap');

    pirelab.getUnitDelayComp(fdNet,datao,decbits,'dataOut',0);
    pirelab.getUnitDelayComp(fdNet,starto,startout,'startOut',0);
    if blockInfo.VectorSize==64
        pirelab.getWireComp(fdNet,valido,validout,'validOut');
    else
        pirelab.getUnitDelayComp(fdNet,valido,validout,'validOut',0);
    end

    pirelab.getUnitDelayComp(fdNet,endo,endout,'endOut',0);
    pirelab.getUnitDelayComp(fdNet,shifto,shift,'shift_reg',0);

end

function dins=demuxSignal(hN,inSignal,sname)



    [indim,hBT]=pirelab.getVectorTypeInfo(inSignal);

    dmuxout=[];
    for i=1:indim
        dins(i)=hN.addSignal(hBT,[sname,num2str(i)]);
        dmuxout=[dmuxout,dins(i)];
    end

    pirelab.getDemuxComp(hN,inSignal,dmuxout);
end
