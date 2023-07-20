function subFilter=elabSubFilterS(this,topNet,dataRate,blockInfo,...
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
    DELAYLINELIMIT2MAP2RAM=blockInfo.DELAYLINELIMIT2MAP2RAM;





    if FOLDINGFACTOR==0&&coefRow==1




        [symmetryStruct,isSymmetry]=getCoefficientsSymmetry(this,subFilter,blockInfo,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,FOLDINGFACTOR);
    else
        symmetryStruct.isSymmetric=0;
    end


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
    if NUMBEROFTAPS==1
        tapCoef=tapCoefSigs;
    else
        tapCoef=tapCoefSigs(1);
    end


    if~strcmpi(blockInfo.synthesisTool,'Altera Quartus II')
        TAP_LATENCY=4;
        MultiplierPipelineRegister=3;
        AdderPipelineRegister=1;
    else
        TAP_LATENCY=3;
        MultiplierPipelineRegister=2;
        AdderPipelineRegister=1;
    end
    blockInfo.TAP_LATENCY=TAP_LATENCY;

    dinDly2=subFilter.addSignal2('Type',din.Type,'Name','dinDly2');
    dinDly2.SimulinkRate=dataRate;
    dinPreAdd=subFilter.addSignal2('Type',din.Type,'Name','dinPreAdd');
    dinPreAdd.SimulinkRate=dataRate;

    tapoutVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','tapoutVld');
    tapoutVld.SimulinkRate=dataRate;
    if zeroOpt
        firFilterTapSystolicWvldInC0=elabFilterTapSystolicWvldInC0(this,subFilter,blockInfo,dataRate,...
        din,addin,dinVld,syncReset,dinDly2,tapout,tapoutVld,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>
    end

    if FOLDINGFACTOR>DELAYLINELIMIT2MAP2RAM
        dlyLineOut1=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','dlyLineOut');
        dlyLineOut1.SimulinkRate=dataRate;
        dlyLineOut2=subFilter.addSignal2('Type',din.Type,'Name','dlyLineOut2');
        dlyLineOut2.SimulinkRate=dataRate;
        dlyLineOutVld1=subFilter.addSignal2('Type',pir_boolean_t,'Name','dlyLineOutVld1');
        dlyLineOutVld1.SimulinkRate=dataRate;
        dlyLineOutVld2=subFilter.addSignal2('Type',pir_boolean_t,'Name','dlyLineOutVld2');
        dlyLineOutVld2.SimulinkRate=dataRate;

        rdEnb=subFilter.addSignal2('Type',pir_boolean_t,'Name','rdEnb');
        rdEnb.SimulinkRate=dataRate;
        wrEnb=subFilter.addSignal2('Type',pir_boolean_t,'Name','wrEnb');
        wrEnb.SimulinkRate=dataRate;

        delayLine1=this.elabDelayLine(subFilter,dataRate,...
        tapout,wrEnb,rdEnb,syncReset,dlyLineOut1,dlyLineOutVld1,...
        FOLDINGFACTOR,TAP_LATENCY);
        delayLine2=this.elabDelayLine(subFilter,dataRate,...
        din,wrEnb,rdEnb,syncReset,dlyLineOut2,dlyLineOutVld2,...
        2*FOLDINGFACTOR,TAP_LATENCY);
    end


    if symmetryStruct.isSymmetric~=0&&NUMBEROFTAPS>1&&~any(symmetryStruct.Exception(2:end))


        firFilterTapSystolicPreAddWvldIn=elabFilterTapSystolicPreAddWvldIn(this,subFilter,blockInfo,dataRate,...
        din,dinPreAdd,tapCoef,addin,dinVld,syncReset,dinDly2,tapout,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,...
        symmetryStruct.isSymmetric);%#ok<*NASGU>








        extraTap=0;
        if symmetryStruct.Exception(1)>0
            extraTap=1;
        end

        ODDSYMM=mod(NUMBEROFTAPS-extraTap,2);

        if symmetryStruct.Exception(1)>0

            if NUMBEROFTAPS==1
                tapCoef=tapCoefSigs;
            else
                tapCoef=tapCoefSigs(1);
            end
            ZERO=subFilter.addSignal2('Type',din.Type,'Name','ZERO');
            ZERO.SimulinkRate=dataRate;
            pirelab.getConstComp(subFilter,ZERO,0);
            if coeffProtoType(1)==0
                pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldInC0,...
                [din,addin,dinVld,syncReset],...
                [dinDly2,tapout,tapoutVld],...
                'FilterTap_1');
            else
                pirelab.instantiateNetwork(subFilter,firFilterTapSystolicPreAddWvldIn,...
                [din,ZERO,tapCoef,addin,dinVld,syncReset],...
                [dinDly2,tapout],...
                'FilterTap_1');
            end
            addin=tapout;
            din=dinDly2;
            tapout=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','tapout');
            tapout.SimulinkRate=dataRate;
            dinDly2=subFilter.addSignal2('Type',din.Type,'Name','dinDly2');
            dinDly2.SimulinkRate=dataRate;
        end
        STARTLOOP=1+extraTap;
        ENDLOOP=floor((NUMBEROFTAPS-extraTap)/2)+extraTap;
        for loop=STARTLOOP:ENDLOOP
            if NUMBEROFTAPS-extraTap==1
                tapCoef=tapCoefSigs;
            else
                tapCoef=tapCoefSigs(loop);
            end

            if loop==floor((NUMBEROFTAPS-extraTap)/2)&&~mod(NUMBEROFTAPS-extraTap,2)
                if coeffProtoType(loop)==0
                    pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldInC0,...
                    [din,addin,dinVld,syncReset],...
                    [dinDly2,tapout,tapoutVld],...
                    ['FilterTap_',int2str(loop)]);
                else
                    pirelab.instantiateNetwork(subFilter,firFilterTapSystolicPreAddWvldIn,...
                    [din,dinPreAdd,tapCoef,addin,dinVld,syncReset],...
                    [dinDly2,tapout],...
                    ['FilterTap_',int2str(loop)]);
                end
                addin=tapout;
                din=dinDly2;
            elseif FOLDINGFACTOR==0
                if coeffProtoType(loop)==0
                    pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldInC0,...
                    [din,addin,dinVld,syncReset],...
                    [dinDly2,tapout,tapoutVld],...
                    ['FilterTap_',int2str(loop)]);
                else
                    pirelab.instantiateNetwork(subFilter,firFilterTapSystolicPreAddWvldIn,...
                    [din,dinPreAdd,tapCoef,addin,dinVld,syncReset],...
                    [dinDly2,tapout],...
                    ['FilterTap_',int2str(loop)]);
                end
                addin=tapout;
                din=dinDly2;
            end
            if loop==ENDLOOP
                if ODDSYMM
                    pirelab.getIntDelayEnabledResettableComp(subFilter,dinDly2,dinPreAdd,dinVld,syncReset,1);
                else
                    pirelab.getWireComp(subFilter,dinDly2,dinPreAdd);
                end
            end
            tapout=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','tapout');
            tapout.SimulinkRate=dataRate;
            dinDly2=subFilter.addSignal2('Type',din.Type,'Name','dinDly2');
            dinDly2.SimulinkRate=dataRate;


        end
        if ODDSYMM
            if NUMBEROFTAPS==1
                tapCoef=tapCoefSigs;
            else
                tapCoef=tapCoefSigs(ceil((NUMBEROFTAPS-extraTap)/2)+extraTap);
            end
            ZERO=subFilter.addSignal2('Type',din.Type,'Name','ZERO');
            ZERO.SimulinkRate=dataRate;
            pirelab.getConstComp(subFilter,ZERO,0);
            if coeffProtoType(ceil((NUMBEROFTAPS-extraTap)/2)+extraTap)==0
                pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldInC0,...
                [din,addin,dinVld,syncReset],...
                [dinDly2,tapout,tapoutVld],...
                ['FilterTap_',int2str(ceil((NUMBEROFTAPS-extraTap)/2)+extraTap)]);
            else
                pirelab.instantiateNetwork(subFilter,firFilterTapSystolicPreAddWvldIn,...
                [din,ZERO,tapCoef,addin,dinVld,syncReset],...
                [dinDly2,tapout],...
                ['FilterTap_',int2str(ceil((NUMBEROFTAPS-extraTap)/2)+extraTap)]);
            end
            addin=tapout;
        end
        AlteraDelay=0;
        if strcmpi(blockInfo.synthesisTool,'Altera Quartus II')
            foutDly=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','foutDly');
            foutDly.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(subFilter,addin,foutDly,dinVld,syncReset,1);
            addin=foutDly;
            AlteraDelay=1;
        end
        vldShift=subFilter.addSignal2('Type',pir_boolean_t,'Name','vldShift');
        vldShift.SimulinkRate=dataRate;
        vldOutTmp=subFilter.addSignal2('Type',pir_boolean_t,'Name','vldOutTmp');
        vldOutTmp.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledResettableComp(subFilter,dinVld,vldShift,dinVld,syncReset,(ceil((NUMBEROFTAPS-extraTap)/2)+extraTap)*AdderPipelineRegister+MultiplierPipelineRegister+AlteraDelay+1);
        pirelab.getBitwiseOpComp(subFilter,[dinVld,vldShift],vldOutTmp,'AND');

        pirelab.getIntDelayEnabledResettableComp(subFilter,vldOutTmp,doutVld,'',syncReset,1);

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
        pirelab.getSwitchComp(subFilter,[dout_cast,ZERO_OUT],muxOut,vldOutTmp,'','==',1);

        pirelab.getIntDelayEnabledResettableComp(subFilter,muxOut,dout,'',syncReset,1);


    else
        firFilterTapSystolicWvldIn=elabFilterTapSystolicWvldIn(this,subFilter,blockInfo,dataRate,...
        din,tapCoef,addin,dinVld,syncReset,dinDly2,tapout,tapoutVld,...
        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);%#ok<*NASGU>

        for loop=1:NUMBEROFTAPS
            if NUMBEROFTAPS==1
                tapCoef=tapCoefSigs;
            else
                tapCoef=tapCoefSigs(loop);
            end

            if loop==NUMBEROFTAPS
                if~isempty(blockInfo.FilterCoefficient)
                    if coeffProtoType(loop)==0&&zeroOpt&&FOLDINGFACTOR==0
                        pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldInC0,...
                        [din,addin,dinVld,syncReset],...
                        [dinDly2,tapout,tapoutVld],...
                        ['FilterTap_',int2str(loop)]);
                    else
                        pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldIn,...
                        [din,tapCoef,addin,dinVld,syncReset],...
                        [dinDly2,tapout,tapoutVld],...
                        ['FilterTap_',int2str(loop)]);
                    end
                else
                    pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldIn,...
                    [din,tapCoef,addin,dinVld,syncReset],...
                    [dinDly2,tapout,tapoutVld],...
                    ['FilterTap_',int2str(loop)]);
                end
                addin=tapout;
            elseif FOLDINGFACTOR==0
                if~isempty(blockInfo.FilterCoefficient)
                    if coeffProtoType(loop)==0&&zeroOpt
                        pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldInC0,...
                        [din,addin,dinVld,syncReset],...
                        [dinDly2,tapout,tapoutVld],...
                        ['FilterTap_',int2str(loop)]);
                    else
                        pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldIn,...
                        [din,tapCoef,addin,dinVld,syncReset],...
                        [dinDly2,tapout,tapoutVld],...
                        ['FilterTap_',int2str(loop)]);
                    end
                else
                    pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldIn,...
                    [din,tapCoef,addin,dinVld,syncReset],...
                    [dinDly2,tapout,tapoutVld],...
                    ['FilterTap_',int2str(loop)]);
                end
                tapoutVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','tapoutVld');
                tapoutVld.SimulinkRate=dataRate;
                addin=tapout;
                din=dinDly2;



            else
                pirelab.instantiateNetwork(subFilter,firFilterTapSystolicWvldIn,...
                [din,tapCoef,addin,dinVld,syncReset],...
                [dinDly2,tapout,tapoutVld],...
                ['FilterTap_',int2str(loop)]);

                dlyLineOut1=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','dlyLineOut1');
                dlyLineOut1.SimulinkRate=dataRate;
                dlyLineOut2=subFilter.addSignal2('Type',dinDly2.Type,'Name','dlyLineOut2');
                dlyLineOut2.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(subFilter,tapout,dlyLineOut1,dinVld,syncReset,FOLDINGFACTOR);
                pirelab.getIntDelayEnabledResettableComp(subFilter,dinDly2,dlyLineOut2,dinVld,syncReset,2*FOLDINGFACTOR);
                tapoutVld=subFilter.addSignal2('Type',pir_boolean_t,'Name','tapoutVld');
                tapoutVld.SimulinkRate=dataRate;
                addin=dlyLineOut1;
                din=dlyLineOut2;


































            end
            tapout=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','tapout');
            tapout.SimulinkRate=dataRate;

            dinDly2=subFilter.addSignal2('Type',din.Type,'Name','dinDly2');
            dinDly2.SimulinkRate=dataRate;
        end
        extDelay=0;
        if strcmpi(blockInfo.synthesisTool,'Altera Quartus II')
            foutDly=subFilter.addSignal2('Type',pir_fixpt_t(1,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH),'Name','foutDly');
            foutDly.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(subFilter,addin,foutDly,dinVld,syncReset,1);
            addin=foutDly;
            tapoutVldA=subFilter.addSignal2('Type',pir_boolean_t,'Name','tapoutVldA');
            tapoutVldA.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(subFilter,tapoutVld,tapoutVldA,'',syncReset,1);
            tapoutVld=tapoutVldA;
            extDelay=1;
        end
        vldShift=subFilter.addSignal2('Type',pir_boolean_t,'Name','vldShift');
        vldShift.SimulinkRate=dataRate;
        vldOutTmp=subFilter.addSignal2('Type',pir_boolean_t,'Name','vldOutTmp');
        vldOutTmp.SimulinkRate=dataRate;

        if FOLDINGFACTOR>0&&NUMBEROFTAPS>1
            extDelay=(NUMBEROFTAPS-1)*FOLDINGFACTOR+extDelay;
        end

        pirelab.getIntDelayEnabledResettableComp(subFilter,dinVld,vldShift,dinVld,syncReset,extDelay+NUMBEROFTAPS*AdderPipelineRegister+MultiplierPipelineRegister);







        pirelab.getBitwiseOpComp(subFilter,[dinVld,vldShift],vldOutTmp,'AND');


        pirelab.getIntDelayEnabledResettableComp(subFilter,vldOutTmp,doutVld,'',syncReset,1);

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
        pirelab.getSwitchComp(subFilter,[dout_cast,ZERO_OUT],muxOut,vldOutTmp,'','==',1);

        pirelab.getIntDelayEnabledResettableComp(subFilter,muxOut,dout,'',syncReset,1);

    end
end


