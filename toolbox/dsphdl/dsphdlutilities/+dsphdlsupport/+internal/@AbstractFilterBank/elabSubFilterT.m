function subFilter=elabSubFilterT(this,topNet,dataRate,blockInfo,...
    din,coef,dinVld,syncReset,dout,doutVld,...
    FOLDINGFACTOR,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    FULLPRECISION,...
    coeffProtoType,zeroOpt)








    InportNames={din.Name,'coefIn',dinVld.Name,syncReset.Name};
    InportTypes=[din.Type,coef.Type,dinVld.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate];

    OutportNames={dout.Name,doutVld.Name};
    OutportTypes=[dout.Type;doutVld.Type];

    subFilter=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','subFilter',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=subFilter.PirInputSignals;
    outputPort=subFilter.PirOutputSignals;

    din=inputPort(1);
    coef=inputPort(2);
    dinVld=inputPort(3);
    syncReset=inputPort(4);
    dout=outputPort(1);
    doutVld=outputPort(2);
    coefType=pirgetdatatypeinfo(coef.Type);


    [coefRow,NUMBEROFTAPS]=size(blockInfo.FilterCoefficient);






    [OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,blockInfo]=getTargetSpecificDT(this,blockInfo);

    [symmetryStruct,isSymmetry]=getCoefficientsSymmetry(this,subFilter,blockInfo,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,FOLDINGFACTOR);



    addin=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','addin');
    addin.SimulinkRate=dataRate;

    pirelab.getConstComp(subFilter,addin,0);

    tapout=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','tapout');
    tapout.SimulinkRate=dataRate;

    if NUMBEROFTAPS==1
        tapCoefSigs=coef;
    else
        tapCoefSigs=coef.split.PirOutputSignals;
    end
    if strcmpi(blockInfo.FilterCoefficientSource,'Input port (Parallel interface)')&&NUMBEROFTAPS>1
        if isSymmetry
            if symmetryStruct(1).isAntiSymm
                for loop=1:length(tapCoefSigs)
                    coefMinus(1,loop)=subFilter.addSignal2('Type',tapCoefSigs(1).Type,'Name','coefMinus');%#ok<AGROW> 
                    pirelab.getUnaryMinusComp(subFilter,tapCoefSigs(loop),coefMinus(loop));
                end
                if mod(NUMBEROFTAPS,2)
                    nextHalf=transpose(coefMinus(1:end-1));
                else
                    nextHalf=transpose(coefMinus);
                end
                tapCoefSigs=[nextHalf;flipud(tapCoefSigs)];
            else
                if mod(NUMBEROFTAPS,2)
                    nextHalf=flipud(tapCoefSigs(1:end-1));
                else
                    nextHalf=flipud(tapCoefSigs);
                end
                tapCoefSigs=[tapCoefSigs;nextHalf];
            end
        else
            tapCoefSigs=flipud(tapCoefSigs);
        end
    end
    if NUMBEROFTAPS==1
        tapCoef=tapCoefSigs;
    else
        tapCoef=tapCoefSigs(1);
    end

    DELAYLINELIMIT2MAP2RAM=blockInfo.DELAYLINELIMIT2MAP2RAM;
    if~isempty(blockInfo.FilterCoefficient)
        [coefRow,~]=size(blockInfo.FilterCoefficient);
    end

    TAP_LATENCY=3;
    tapoutVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','tapoutVld');
    tapoutVld.SimulinkRate=dataRate;
    pirelab.getIntDelayEnabledResettableComp(subFilter,dinVld,tapoutVld,'',syncReset,TAP_LATENCY);
    multVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','multVld');
    multVld.SimulinkRate=dataRate;

    if zeroOpt
        firFilterTapWvldInC0=elabFilterTapWvldInC0(this,subFilter,blockInfo,dataRate,...
        addin,multVld,syncReset,tapout,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>
    end
    if FOLDINGFACTOR<=DELAYLINELIMIT2MAP2RAM

        pirelab.getIntDelayEnabledResettableComp(subFilter,dinVld,multVld,'','',TAP_LATENCY-1);
        firFilterTapWvldIn=elabFilterTapWvldIn(this,subFilter,blockInfo,dataRate,...
        din,tapCoef,addin,multVld,syncReset,tapout,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>
    else
        firFilterTap=elabFilterTap(this,subFilter,blockInfo,dataRate,...
        din,tapCoef,addin,syncReset,tapout,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>
        dlyLineOut1=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','dlyLineOut');
        dlyLineOut1.SimulinkRate=dataRate;
        dlyLineOutVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','dlyLineOutVld');
        dlyLineOutVld.SimulinkRate=dataRate;
        wrEnb=subFilter.addSignal2('Type',pir_boolean_t,'Name','wrEnb');
        wrEnb.SimulinkRate=dataRate;
        rdEnb=subFilter.addSignal2('Type',pir_boolean_t,'Name','rdEnb');
        rdEnb.SimulinkRate=dataRate;
        delayLine=this.elabDelayLine(subFilter,dataRate,...
        tapout,wrEnb,rdEnb,syncReset,dlyLineOut1,dlyLineOutVld,...
        FOLDINGFACTOR,TAP_LATENCY);
    end

    if isSymmetry
        multVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','multVld');
        multVld.SimulinkRate=dataRate;
        multOut=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','multOut');
        multVld.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledResettableComp(subFilter,dinVld,multVld,'',syncReset,TAP_LATENCY-1);
        firFilterTapWMultOut=elabFilterTapWMultOut(this,subFilter,blockInfo,dataRate,...
        din,tapCoef,addin,multVld,syncReset,tapout,multOut,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>
        firFilterTapPostAdd=elabFilterTapPostAdd(this,subFilter,blockInfo,dataRate,...
        addin,multOut,multVld,syncReset,tapout,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>
        firFilterTapPostSub=elabFilterTapPostSub(this,subFilter,blockInfo,dataRate,...
        addin,multOut,multVld,syncReset,tapout,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>
    end

    for loop=1:NUMBEROFTAPS
        if NUMBEROFTAPS==1
            tapCoef=tapCoefSigs;
        else
            tapCoef=tapCoefSigs(loop);
        end

        if loop==NUMBEROFTAPS
            if FOLDINGFACTOR<=DELAYLINELIMIT2MAP2RAM
                if coeffProtoType(loop)==0&&zeroOpt&&FOLDINGFACTOR==0
                    pirelab.instantiateNetwork(subFilter,firFilterTapWvldInC0,...
                    [addin,multVld,syncReset],...
                    tapout,...
                    ['FilterTap_',int2str(loop)]);
                elseif strcmpi(symmetryStruct(loop).Type,'DSPFull')
                    pirelab.instantiateNetwork(subFilter,firFilterTapWvldIn,...
                    [din,tapCoef,addin,multVld,syncReset],...
                    tapout,...
                    ['FilterTap_',int2str(loop)]);
                else
                    if strcmpi(symmetryStruct(loop).Type,'DSPPostAdd')
                        pirelab.instantiateNetwork(subFilter,firFilterTapPostAdd,...
                        [addin,symmetryStruct(loop).Signal,multVld,syncReset],...
                        tapout,...
                        ['FilterTapPostAdd_',int2str(loop)]);
                    else
                        pirelab.instantiateNetwork(subFilter,firFilterTapPostSub,...
                        [addin,symmetryStruct(loop).Signal,multVld,syncReset],...
                        tapout,...
                        ['FilterTapPostSub_',int2str(loop)]);
                    end
                end
            else
                if coeffProtoType(loop)==0&&zeroOpt&&FOLDINGFACTOR==0
                    pirelab.instantiateNetwork(subFilter,firFilterTapC0,...
                    [addin,syncReset],...
                    tapout,...
                    ['FilterTap_',int2str(loop)]);
                elseif strcmpi(symmetryStruct(loop).Type,'DSPFull')
                    pirelab.instantiateNetwork(subFilter,firFilterTap,...
                    [din,tapCoef,addin,syncReset],...
                    tapout,...
                    ['FilterTap_',int2str(loop)]);
                else
                    if strcmpi(symmetryStruct(loop).Type,'DSPPostAdd')
                        pirelab.instantiateNetwork(subFilter,firFilterTapPostAdd,...
                        [addin,symmetryStruct(loop).Signal,multVld,syncReset],...
                        tapout,...
                        ['FilterTapPostAdd_',int2str(loop)]);
                    else
                        pirelab.instantiateNetwork(subFilter,firFilterTapPostSub,...
                        [addin,symmetryStruct(loop).Signal,multVld,syncReset],...
                        tapout,...
                        ['FilterTapPostSub_',int2str(loop)]);
                    end
                end
            end
            addin=tapout;
        elseif FOLDINGFACTOR==0
            if coeffProtoType(loop)==0&&zeroOpt
                pirelab.instantiateNetwork(subFilter,firFilterTapWvldInC0,...
                [addin,multVld,syncReset],...
                tapout,...
                ['FilterTap_',int2str(loop)]);

            elseif strcmpi(symmetryStruct(loop).Type,'DSPFull')
                pirelab.instantiateNetwork(subFilter,firFilterTapWvldIn,...
                [din,tapCoef,addin,multVld,syncReset],...
                tapout,...
                ['FilterTap_',int2str(loop)]);
            elseif strcmpi(symmetryStruct(loop).Type,'DSPMultOut')
                pirelab.instantiateNetwork(subFilter,firFilterTapWMultOut,...
                [din,tapCoef,addin,multVld,syncReset],...
                [tapout,symmetryStruct(loop).Signal],...
                ['FilterTapMultOut_',int2str(loop)]);
            else
                if strcmpi(symmetryStruct(loop).Type,'DSPPostAdd')
                    pirelab.instantiateNetwork(subFilter,firFilterTapPostAdd,...
                    [addin,symmetryStruct(loop).Signal,multVld,syncReset],...
                    tapout,...
                    ['FilterTapPostAdd_',int2str(loop)]);
                else
                    pirelab.instantiateNetwork(subFilter,firFilterTapPostSub,...
                    [addin,symmetryStruct(loop).Signal,multVld,syncReset],...
                    tapout,...
                    ['FilterTapPostSub_',int2str(loop)]);
                end
            end
            addin=tapout;
        elseif FOLDINGFACTOR<=DELAYLINELIMIT2MAP2RAM
            pirelab.instantiateNetwork(subFilter,firFilterTapWvldIn,...
            [din,tapCoef,addin,multVld,syncReset],...
            tapout,...
            ['FilterTap_',int2str(loop)]);
            dlyLineOut1=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','dlyLineOut');
            dlyLineOut1.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(subFilter,tapout,dlyLineOut1,multVld,syncReset,FOLDINGFACTOR);
            addin=dlyLineOut1;
        else
            pirelab.instantiateNetwork(subFilter,firFilterTap,...
            [din,tapCoef,addin,syncReset],...
            tapout,...
            ['FilterTap_',int2str(loop)]);
            dlyLineOut1=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','dlyLineOut');
            dlyLineOut1.SimulinkRate=dataRate;
            dlyLineOutVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','dlyLineOutVld');
            dlyLineOutVld.SimulinkRate=dataRate;


            rdEnb=subFilter.addSignal2('Type',pir_boolean_t,'Name','rdEnb');
            rdEnb.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(subFilter,dinVld,rdEnb,'',syncReset,TAP_LATENCY-2);
            wrEnb=tapoutVld;

            pirelab.instantiateNetwork(subFilter,delayLine,...
            [tapout,wrEnb,rdEnb,syncReset],...
            [dlyLineOut1,dlyLineOutVld],...
            ['delayLine_',int2str(loop)]);
            addin=dlyLineOut1;
        end
        tapout=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','tapout');
        tapout.SimulinkRate=dataRate;

    end
    pirelab.getIntDelayEnabledResettableComp(subFilter,tapoutVld,doutVld,'',syncReset,1);
    dout_cast=subFilter.addSignal2('Type',dout.Type,'Name','dout_cast');
    dout_cast.SimulinkRate=dataRate;
    ZERO_OUT=subFilter.addSignal2('Type',dout_cast.Type,'Name','ZERO_OUT');
    ZERO_OUT.SimulinkRate=dataRate;
    muxOut=subFilter.addSignal2('Type',dout_cast.Type,'Name','muxOut');
    muxOut.SimulinkRate=dataRate;
    pirelab.getConstComp(subFilter,ZERO_OUT,0);
    if FULLPRECISION
        pirelab.getWireComp(subFilter,addin,dout_cast);
    else
        pirelab.getDTCComp(subFilter,addin,dout_cast,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    end
    pirelab.getSwitchComp(subFilter,[dout_cast,ZERO_OUT],muxOut,tapoutVld,'','==',1);
    pirelab.getIntDelayEnabledResettableComp(subFilter,muxOut,dout,'',syncReset,1);


end


