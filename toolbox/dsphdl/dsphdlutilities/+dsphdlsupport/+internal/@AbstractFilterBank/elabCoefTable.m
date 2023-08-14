function CoefTable=elabCoefTable(this,FilterImpl,blockInfo,dataRate,...
    DATA_VECSIZE,inputIndex,FilterCoefficients,...
    rdEnb,syncReset,...
    CoefOut,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH)




    InportNames={rdEnb.Name,syncReset.Name};
    InportTypes=[rdEnb.Type;syncReset.Type];
    InportRates=[dataRate;dataRate];

    OutportNames={CoefOut.Name};
    OutportTypes=[CoefOut.Type];

    CoefTable=pirelab.createNewNetwork(...
    'Network',FilterImpl,...
    'Name','FilterCoef',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=CoefTable.PirInputSignals;
    outputPort=CoefTable.PirOutputSignals;

    rdEnb=inputPort(1);
    syncReset=inputPort(2);
    CoefOut=outputPort(1);


    if strcmpi(blockInfo.FilterCoefficientSource,'Input port (Parallel interface)')
        CoefDT=pirgetdatatypeinfo(CoefOut.Type);
        NoOfSubFilter=1;
        NoOfTaps=CoefDT.dims;


    else
        CoefDT=getCoefficientsDT(this,blockInfo);
        coefficients=cast(blockInfo.FilterCoefficient,'like',fi(0,1,CoefDT.WordLength,CoefDT.FractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest'));
        [NoOfSubFilter,~]=size(coefficients);
        [~,NoOfTaps]=size(FilterCoefficients);
    end


    COEFADDR_WORDLENGTH=ceil(log2(double(NoOfSubFilter/DATA_VECSIZE)));
    CNTLIMIT=floor(NoOfSubFilter/DATA_VECSIZE)-1;
    if COEFADDR_WORDLENGTH>0
        CoefAddr=CoefTable.addSignal2('Type',pir_fixpt_t(0,COEFADDR_WORDLENGTH,0),'Name','CoefAddr');%#ok<*AGROW>
        CoefAddr.SimulinkRate=dataRate;
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
        '+dsphdlsupport','+internal','@AbstractFilterBank','cgireml','CoefAddrGen.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char')';
        fclose(fid);

        desc='CoefAddr';

        coefAddrGen=CoefTable.addComponent2(...
        'kind','cgireml',...
        'Name','CoefAddr',...
        'InputSignals',rdEnb,...
        'OutputSignals',CoefAddr,...
        'EMLFileName','CoefAddrGen',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{COEFADDR_WORDLENGTH,CNTLIMIT},...
        'ExternalSynchronousResetSignal',syncReset,...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);

        coefAddrGen.runConcurrencyMaximizer(0);

    else
        CoefAddr=CoefTable.addSignal2('Type',pir_boolean_t,'Name','CoefAddr');%#ok<*AGROW>
        CoefAddr.SimulinkRate=dataRate;
        pirelab.getConstComp(CoefTable,CoefAddr,0);
    end


    for tapIndex=1:NoOfTaps

        tapCoef=FilterCoefficients(:,tapIndex);
        index=(inputIndex:DATA_VECSIZE:length(tapCoef));
        CoefValue=tapCoef(index);
        CoefData(tapIndex)=CoefTable.addSignal2('Type',pir_fixpt_t(1,COEF_WORDLENGTH,COEF_FRACTIONLENGTH),'Name','CoefData');%#ok<AGROW>
        CoefData(tapIndex).SimulinkRate=dataRate;%#ok<*AGROW>

        if length(CoefValue)>1
            CoefReg(tapIndex)=CoefTable.addSignal2('Type',pir_fixpt_t(1,COEF_WORDLENGTH,COEF_FRACTIONLENGTH),'Name','CoefReg');%#ok<AGROW>
            CoefReg(tapIndex).SimulinkRate=dataRate;
            CoefROM=pirelab.getDirectLookupComp(CoefTable,CoefAddr,CoefData(tapIndex),CoefValue,'Coef_table');
            CoefROM.addComment(['CoefTable_',num2str(tapIndex)]);
            pirelab.getUnitDelayComp(CoefTable,CoefData(tapIndex),CoefReg(tapIndex),'FilterCoef',0,false);
        else
            CoefReg(tapIndex)=CoefTable.addSignal2('Type',pir_fixpt_t(1,COEF_WORDLENGTH,COEF_FRACTIONLENGTH),'Name','CoefReg');%#ok<AGROW>
            CoefReg(tapIndex).SimulinkRate=dataRate;
            CoefROM=pirelab.getConstComp(CoefTable,CoefData(tapIndex),CoefValue,'Coef_reg');
            CoefROM.addComment(['CoefReg_',num2str(tapIndex)]);
            pirelab.getWireComp(CoefTable,CoefData(tapIndex),CoefReg(tapIndex));
        end

    end

    pirelab.getMuxComp(CoefTable,CoefReg,CoefOut);
