function twdlROM=elabRADIX22FFT_TWDL(this,hN,blockInfo,dataRate,R2StageNum,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,notPowerOf4,din_vld,softReset,twiddle_re,twiddle_im,twiddle_vld)





    InportNames={din_vld.Name,softReset.Name};
    InportTypes=[din_vld.Type;softReset.Type];
    InportRates=[dataRate;dataRate];

    OutportNames={twiddle_re.Name,twiddle_im.Name,twiddle_vld.Name};
    OutportTypes=[twiddle_re.Type;twiddle_im.Type;twiddle_vld.Type];

    twdlROM=pirelab.createNewNetwork(...
    'Network',hN,...
    'Name',['TWDLROM_',int2str(R2StageNum),'_',int2str(inIndex)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=twdlROM.PirInputSignals;
    outputPort=twdlROM.PirOutputSignals;

    din_vld=inputPort(1);
    softReset=inputPort(2);
    twiddle_re=outputPort(1);
    twiddle_im=outputPort(2);
    twiddle_vld=outputPort(3);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        syncReset=softReset;
    else
        syncReset='';
    end

    fimath_int=fimath('OverflowAction','Wrap','RoundingMethod','Floor');
    TWDL_WORDLENGTH=twiddle_re.Type.WordLength;
    TWDL_FRACTIONLENGTH=twiddle_re.Type.FractionLength;
    reqNumberOfTwdls=(0:blockInfo.FFTLength)/(blockInfo.FFTLength);
    reqNumberOfTwdls=reqNumberOfTwdls(reqNumberOfTwdls<1/8);
    twiddleTable=fi(exp(-1i*2*pi*reqNumberOfTwdls).',1,TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH,'RoundingMethod','Convergent','OverflowAction','Wrap');
    twiddle_data=fi(twiddleTable,1,TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH,fimath_int);


    twdlAddr=twdlROM.addSignal2('Type',pir_ufixpt_t(max(log2(blockInfo.FFTLength/8),1),0),'Name','twdlAddr');
    twdlAddr.SimulinkRate=dataRate;
    twdlAddrVld=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdlAddrVld');
    twdlAddrVld.SimulinkRate=dataRate;

    twdlVldReg=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdlVldReg');
    twdlVldReg.SimulinkRate=dataRate;
    twdlOctant=twdlROM.addSignal2('Type',pir_ufixpt_t(3,0),'Name','twdlOctant');
    twdlOctant.SimulinkRate=dataRate;
    twdlOctantReg=twdlROM.addSignal2('Type',pir_ufixpt_t(3,0),'Name','twdlOctantReg');
    twdlOctantReg.SimulinkRate=dataRate;
    twdl45=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdl45');
    twdl45.SimulinkRate=dataRate;
    twdl45Reg=twdlROM.addSignal2('Type',pir_boolean_t,'Name','twdl45Reg');
    twdl45Reg.SimulinkRate=dataRate;

    twiddleS_re=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleS_re');
    twiddleS_re.SimulinkRate=dataRate;
    twiddleS_im=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleS_im');
    twiddleS_im.SimulinkRate=dataRate;

    twiddleReg_re=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleReg_re');
    twiddleReg_re.SimulinkRate=dataRate;
    twiddleReg_im=twdlROM.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twiddleReg_im');
    twiddleReg_im.SimulinkRate=dataRate;

    twiddleROM1=pirelab.getDirectLookupComp(twdlROM,twdlAddr,twiddleS_re,twiddle_data.real,'Twiddle_re');
    twiddleROM1.addComment('Twiddle ROM1');
    twiddleROM2=pirelab.getDirectLookupComp(twdlROM,twdlAddr,twiddleS_im,twiddle_data.imag,'Twiddle_im');
    twiddleROM2.addComment('Twiddle ROM2');

    pirelab.getUnitDelayComp(twdlROM,twiddleS_re,twiddleReg_re,'TWIDDLEROM_RE',0,blockInfo.resetnone);
    pirelab.getUnitDelayComp(twdlROM,twiddleS_im,twiddleReg_im,'TWIDDLEROM_IM',0,blockInfo.resetnone);

    [CNT_IC,CNT_INCR,PHASE_IC,PHASE_INCR]=initialConditions(R2StageNum,DATA_VECSIZE,blockInfo.FFTLength,BITREVERSEDINPUT,notPowerOf4);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@AbstractFFT','cgireml','Radix22TwdlMapping.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22TwdlMapping';

    twdlMapping=twdlROM.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22TwdlMapping',...
    'InputSignals',[din_vld],...
    'OutputSignals',[twdlAddr,twdlAddrVld,twdlOctant,twdl45],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','Radix22TwdlMapping',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.FFTLength,R2StageNum,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,CNT_IC(inIndex),CNT_INCR,PHASE_IC(inIndex),PHASE_INCR},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    twdlMapping.runConcurrencyMaximizer(0);

    pirelab.getIntDelayEnabledResettableComp(twdlROM,twdlAddrVld,twiddle_vld,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(twdlROM,twdlOctant,twdlOctantReg,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(twdlROM,twdl45,twdl45Reg,'',syncReset,1);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix22TwdlOctCorr.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22TwdlOctCorr';

    twdlCorr=twdlROM.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22TwdlOctCorr',...
    'InputSignals',[twiddleReg_re,twiddleReg_im,twdlOctantReg,twdl45Reg],...
    'OutputSignals',[twiddle_re,twiddle_im],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','Radix22TwdlOctCorr',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    twdlCorr.runConcurrencyMaximizer(0);


    function[CNT_IC,CNT_INCR,PHASE_IC,PHASE_INCR]=initialConditions(STAGENUMBER,INVECSIZE,FFTLENGTH,BITREVERSEDINPUT,notPowerOf4)

        fimath_int=fimath('OverflowAction','Wrap','RoundingMethod','Floor');
        if BITREVERSEDINPUT
            REPEAT=STAGENUMBER-3;
            MEMSIZE=floor(2^(STAGENUMBER-1)/double(INVECSIZE));
            MAXCNT=double(FFTLENGTH/(2^(STAGENUMBER-1)));
            CNTWIDTH=log2(MAXCNT);

            if MEMSIZE>=4
                CNT_IC=repmat(fi(0,0,CNTWIDTH,0,fimath_int),1,INVECSIZE);
                CNT_INCR=fi(1,0,CNTWIDTH,0,fimath_int);
            elseif MEMSIZE==2
                CNT_IC=repmat(fi(0,0,CNTWIDTH,0,fimath_int),1,INVECSIZE);
                CNT_INCR=fi(1,0,CNTWIDTH,0,fimath_int);
            elseif MEMSIZE==1
                CNT_IC=repmat(fi(0,0,CNTWIDTH,0,fimath_int),1,INVECSIZE);
                CNT_INCR=fi(1,0,CNTWIDTH,0,fimath_int);
            elseif notPowerOf4
                CNTWIDTH=log2(2^(STAGENUMBER-3))+1;
                CNT_INCR=fi(0,0,CNTWIDTH,0,fimath_int);
                CNT_IC=repmat([fi(0,0,CNTWIDTH,0,fimath_int),fi(2^(STAGENUMBER-3),0,CNTWIDTH,0,fimath_int)],1,4*2^REPEAT);
            else
                CNT_INCR=INVECSIZE/(4*2^(STAGENUMBER-3));
                CNT_IC_TMP=[];
                for IC=0:CNT_INCR-1
                    CNT_IC_TMP=[CNT_IC_TMP,repmat(IC,1,4*2^REPEAT)];%#ok<AGROW>
                end
                CNT_IC=fi(CNT_IC_TMP,0,CNTWIDTH,0,fimath_int);
            end

            if MEMSIZE>=4
                PHASE_IC=fi(repmat(0,1,INVECSIZE),0,2,0,fimath_int);
                PHASE_INCR=fi(1,0,2,0,fimath_int);
            elseif MEMSIZE==2
                PHASE_IC=fi([repmat(0,1,INVECSIZE/2),repmat(1,1,INVECSIZE/2)],0,2,0,fimath_int);%#ok<*REPMAT> %INPUTINDEX - 1;
                PHASE_INCR=fi(2,0,2,0,fimath_int);
            elseif MEMSIZE==1
                PHASE_IC=fi([repmat(0,1,INVECSIZE/4),repmat(1,1,INVECSIZE/4),repmat(2,1,INVECSIZE/4),repmat(3,1,INVECSIZE/4)],0,2,0,fimath_int);
                PHASE_INCR=fi(0,0,2,0,fimath_int);
            elseif notPowerOf4
                PHASE_INCR=fi(0,0,2,0,fimath_int);
                PHASE_IC=fi([repmat([0,0],1,2^REPEAT),repmat([1,1],1,2^REPEAT),repmat([2,2],1,2^REPEAT),repmat([3,3],1,2^REPEAT)],0,2,0,fimath_int);
            else
                PHASE_IC=fi(repmat([repmat(0,1,2^REPEAT),repmat(1,1,2^REPEAT),repmat(2,1,2^REPEAT),repmat(3,1,2^REPEAT)],1,CNT_INCR),0,2,0,fimath_int);
                PHASE_INCR=fi(0,0,2,0,fimath_int);
            end
        else
            MAXCNT=FFTLENGTH/4;
            CNTWIDTH=log2(double(MAXCNT));
            CNT_IC=repmat(fi(0,0,CNTWIDTH,0,fimath_int),1,INVECSIZE);
            CNT_INCR=4^((STAGENUMBER-3)/2)*INVECSIZE;
            PHASE_IC=fi(repmat(0,1,INVECSIZE),0,2,0,fimath_int);
            PHASE_INCR=fi(1,0,2,0,fimath_int);
        end
