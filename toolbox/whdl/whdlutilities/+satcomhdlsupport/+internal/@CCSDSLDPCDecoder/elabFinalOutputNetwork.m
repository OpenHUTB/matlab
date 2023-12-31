function fONet=elabFinalOutputNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_boolean_t;
    ufix2Type=pir_ufixpt_t(2,0);
    outType=pir_ufixpt_t(blockInfo.outWL,0);
    vType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);
    if blockInfo.scalarFlag
        dType=pirelab.getPirVectorType(ufix1Type,1);
    else
        dType=pirelab.getPirVectorType(ufix1Type,8);
    end


    fONet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FinalOutput',...
    'Inportnames',{'reset','iterDone','valid','data','outLen','shiftSel'},...
    'InportTypes',[ufix1Type,ufix1Type,ufix1Type,vType,outType,ufix2Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'data','start','end','valid'},...
    'OutportTypes',[dType,ufix1Type,ufix1Type,ufix1Type,]...
    );



    reset=fONet.PirInputSignals(1);
    iterdone=fONet.PirInputSignals(2);
    valid=fONet.PirInputSignals(3);
    data=fONet.PirInputSignals(4);
    outlen=fONet.PirInputSignals(5);
    shiftsel=fONet.PirInputSignals(6);

    dataout=fONet.PirOutputSignals(1);
    startout=fONet.PirOutputSignals(2);
    endout=fONet.PirOutputSignals(3);
    validout=fONet.PirOutputSignals(4);

    iterdone_reg=fONet.addSignal(ufix1Type,'iterDoneReg');
    iterdone_neg=fONet.addSignal(ufix1Type,'iterDoneNeg');
    pirelab.getUnitDelayComp(fONet,iterdone,iterdone_reg,'',0);
    pirelab.getLogicComp(fONet,iterdone_reg,iterdone_neg,'not');

    out_start=fONet.addSignal(ufix1Type,'outStart');
    pirelab.getLogicComp(fONet,[iterdone,iterdone_neg],out_start,'and');

    start_reg=fONet.addSignal(ufix1Type,'startReg');
    starto=fONet.addSignal(ufix1Type,'startO');
    endo=fONet.addSignal(ufix1Type,'endO');
    valido=fONet.addSignal(ufix1Type,'validO');
    datao=fONet.addSignal(dataout.Type,'dataO');

    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        if blockInfo.scalarFlag
            pirelab.getIntDelayComp(fONet,out_start,start_reg,18,'',0);


            fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
            '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','outputGenerationSerial.m'),'r');
            outputGenerationSerial=fread(fid,Inf,'char=>char');
            fclose(fid);
            fONet.addComponent2(...
            'kind','cgireml',...
            'Name','outputGenerationSerial',...
            'InputSignals',[reset,start_reg,iterdone,data],...
            'OutputSignals',[starto,endo,valido,datao],...
            'ExternalSynchronousResetSignal','',...
            'EMLFileName','outputGenerationSerial',...
            'EMLFileBody',outputGenerationSerial,...
            'EMLFlag_TreatInputIntsAsFixpt',true);
        else
            rdvalid=fONet.addSignal(ufix1Type,'rdValid');
            pirelab.getLogicComp(fONet,[out_start,valid],rdvalid,'or');
            startr=fONet.addSignal(ufix1Type,'startR');
            validr=fONet.addSignal(ufix1Type,'validR');
            datar=fONet.addSignal(data.Type,'dataR');
            valid_reg=fONet.addSignal(ufix1Type,'validReg');


            fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
            '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','dataRearrange.m'),'r');
            dataRearrange=fread(fid,Inf,'char=>char');
            fclose(fid);
            fONet.addComponent2(...
            'kind','cgireml',...
            'Name','dataRearrange',...
            'InputSignals',[reset,data,out_start,iterdone,rdvalid],...
            'OutputSignals',[startr,validr,datar],...
            'ExternalSynchronousResetSignal','',...
            'EMLFileName','dataRearrange',...
            'EMLFileBody',dataRearrange,...
            'EMLFlag_TreatInputIntsAsFixpt',true);
            pirelab.getIntDelayComp(fONet,startr,start_reg,8,'',0);
            pirelab.getIntDelayComp(fONet,validr,valid_reg,8,'',0);


            fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
            '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','outputGenerationVector.m'),'r');
            outputGenerationVector=fread(fid,Inf,'char=>char');
            fclose(fid);
            fONet.addComponent2(...
            'kind','cgireml',...
            'Name','outputGenerationVector',...
            'InputSignals',[reset,start_reg,valid_reg,datar],...
            'OutputSignals',[starto,endo,valido,datao],...
            'ExternalSynchronousResetSignal','',...
            'EMLFileName','outputGenerationVector',...
            'EMLFileBody',outputGenerationVector,...
            'EMLFlag_TreatInputIntsAsFixpt',true);
        end

    else
        pirelab.getUnitDelayComp(fONet,out_start,start_reg,'',0);


        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','outputGeneration.m'),'r');
        outputGeneration=fread(fid,Inf,'char=>char');
        fclose(fid);
        fONet.addComponent2(...
        'kind','cgireml',...
        'Name','outputGeneration',...
        'InputSignals',[reset,start_reg,iterdone,data,outlen,shiftsel],...
        'OutputSignals',[starto,endo,valido,datao],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','outputGeneration',...
        'EMLFileBody',outputGeneration,...
        'EmlParams',{blockInfo.scalarFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end
    pirelab.getUnitDelayComp(fONet,starto,startout,'',0);
    pirelab.getUnitDelayComp(fONet,endo,endout,'',0);
    pirelab.getUnitDelayComp(fONet,valido,validout,'',0);
    pirelab.getUnitDelayComp(fONet,datao,dataout,'',0);

end


