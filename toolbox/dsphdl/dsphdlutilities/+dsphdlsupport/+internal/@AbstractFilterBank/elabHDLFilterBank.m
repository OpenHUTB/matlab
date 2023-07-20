function elabHDLFilterBank(this,FilterImpl,blockInfo)









    insignals=FilterImpl.PirInputSignals;

    outsignals=FilterImpl.PirOutputSignals;

    for inputIndex=1:length(outsignals)
        outsignals(inputIndex).SimulinkRate=insignals(1).SimulinkRate;
    end

    dataIn=insignals(1);
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    dataRate=dataIn.simulinkRate;
    validIn=insignals(2);
    validIn.SimulinkRate=dataRate;
    if blockInfo.inMode(2)&&~blockInfo.inResetSS
        if strcmpi(blockInfo.FilterCoefficientSource,'Property')
            syncReset=insignals(3);
        else
            syncReset=insignals(4);
        end
        syncReset.SimulinkRate=dataRate;
    else
        syncReset=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;
        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(FilterImpl,syncReset,false);
        end
    end



    DATAIN_SIGN=dataInType.issigned;
    DATAIN_WORDLENGTH=dataInType.wordsize;
    DATAIN_FRACTIONLENGTH=dataInType.binarypoint;
    DATAIN_VECSIZE=dataInType.dims;
    DATAIN_ISCOMPLEX=logical(dataInType.iscomplex);
    if~DATAIN_SIGN
        DATAIN_WORDLENGTH=DATAIN_WORDLENGTH+1;
        DATAIN_SIGN=1;
    end
    blockInfo.InputDataIsReal=~DATAIN_ISCOMPLEX;
    blockInfo.DATA_WORDLENGTH=DATAIN_WORDLENGTH;
    blockInfo.DATA_FRACTIONLENGTH=DATAIN_FRACTIONLENGTH;
    blockInfo.DATA_SIGNED=DATAIN_SIGN;

    din_type=pir_fixpt_t(DATAIN_SIGN,DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH);


    dataOut=outsignals(1);
    dataOutType=pirgetdatatypeinfo(dataOut.Type);
    DATAOUT_WORDLENGTH=dataOutType.wordsize;
    DATAOUT_FRACTIONLENGTH=dataOutType.binarypoint;
    DATAOUT_SIGN=dataOutType.issigned;
    DATAOUT_ISCOMPLEX=dataOutType.iscomplex;
    dout_type=pir_fixpt_t(DATAOUT_SIGN,DATAOUT_WORDLENGTH,DATAOUT_FRACTIONLENGTH);



    if strcmpi(blockInfo.FilterCoefficientSource,'Input port (Parallel interface)')
        coeffIn=insignals(3);
        CoefDT=pirgetdatatypeinfo(coeffIn.Type);
        COEF_ISCOMPLEX=CoefDT.iscomplex;
        COEF_WORDLENGTH=CoefDT.wordsize;
        COEF_FRACTIONLENGTH=CoefDT.binarypoint;
        COEF_SIGNED=CoefDT.issigned;
        coefficients=[];

        [NoOfSubFilter,NoOfTaps]=size(blockInfo.FilterCoefficient);
        if NoOfSubFilter==1
            NoOfTaps=CoefDT.dims;
        end
        FOLDINGFACTOR=double(NoOfSubFilter/DATAIN_VECSIZE-1);

        if~COEF_SIGNED
            COEF_SIGNED=1;
            COEF_WORDLENGTH=COEF_WORDLENGTH+1;
        end
        if COEF_ISCOMPLEX&&DATAIN_ISCOMPLEX
            COEF_WORDLENGTH=COEF_WORDLENGTH+1;
        end
        if COEF_ISCOMPLEX
            coefPirType=pir_complex_t(pir_fixpt_t(COEF_SIGNED,COEF_WORDLENGTH,COEF_FRACTIONLENGTH));
        else
            coefPirType=pir_fixpt_t(COEF_SIGNED,COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
        end
        if NoOfTaps==1
            cType=coefPirType;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(NoOfTaps);
            hAF.addBaseType(coefPirType);
            hAF.VectorOrientation='column';
            cType=hdlcoder.tp_array(hAF);
        end


        if NoOfSubFilter==1
            coeffIn_signed(1)=FilterImpl.addSignal2('Type',cType,'Name','coeffIn_signed');
            coeffIn_signed(1).SimulinkRate=dataRate;
            coeffIn_reshaped=reshapeFilterCoeffInput(this,FilterImpl,coeffIn,blockInfo.FilterStructure,NoOfSubFilter);
            pirelab.getDTCComp(FilterImpl,coeffIn_reshaped,coeffIn_signed(1));
        else
            coeffIn_reshaped=reshapeFilterCoeffInput(this,FilterImpl,coeffIn,blockInfo.FilterStructure,NoOfSubFilter);
            coeffIn_reshaped=[coeffIn_reshaped(end),coeffIn_reshaped(1:end-1)];
            for idx=1:NoOfSubFilter
                coeffIn_signed(idx)=FilterImpl.addSignal2('Type',cType,'Name','coeffIn_signed');
                coeffIn_signed(idx).SimulinkRate=dataRate;
                pirelab.getDTCComp(FilterImpl,coeffIn_reshaped(idx),coeffIn_signed(idx));
            end
        end


        if NoOfTaps==1
            cTypeR=pir_fixpt_t(COEF_SIGNED,COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(NoOfTaps);
            hAF.addBaseType(pir_fixpt_t(COEF_SIGNED,COEF_WORDLENGTH,COEF_FRACTIONLENGTH));
            hAF.VectorOrientation='column';
            cTypeR=hdlcoder.tp_array(hAF);
        end
        for idx=1:NoOfSubFilter
            if COEF_ISCOMPLEX
                coeffIn_re(idx)=FilterImpl.addSignal2('Type',cTypeR,'Name','coeffIn_re');
                coeffIn_re(idx).SimulinkRate=dataRate;
                coeffIn_im(idx)=FilterImpl.addSignal2('Type',cTypeR,'Name','coeffIn_im');
                coeffIn_im(idx).SimulinkRate=dataRate;
                pirelab.getComplex2RealImag(FilterImpl,coeffIn_signed(idx),[coeffIn_re(idx),coeffIn_im(idx)],'Real and Imag');
                CoefOut(idx)=FilterImpl.addSignal2('Type',cTypeR,'Name','CoefOut');
            else
                CoefOut(idx)=FilterImpl.addSignal2('Type',coeffIn_signed(idx).Type,'Name','CoefOut');
                CoefOut(idx).SimulinkRate=dataRate;
            end
        end
    else
        CoefDT=getCoefficientsDT(this,blockInfo);
        COEF_SIGNED=CoefDT.Signed;
        COEF_ISCOMPLEX=~isreal(blockInfo.FilterCoefficient);
        COEF_WORDLENGTH=CoefDT.WordLength;
        COEF_FRACTIONLENGTH=-CoefDT.FractionLength;
        [NoOfSubFilter,NoOfTaps]=size(blockInfo.FilterCoefficient);
        FOLDINGFACTOR=double(NoOfSubFilter/DATAIN_VECSIZE-1);

        if~COEF_SIGNED
            COEF_WORDLENGTH=CoefDT.WordLength+1;
            COEF_SIGNED=1;
        end

        coefficients=fi(blockInfo.FilterCoefficient,COEF_SIGNED,COEF_WORDLENGTH,-COEF_FRACTIONLENGTH,'OverflowAction','Saturate','RoundingMethod','Nearest');



        if COEF_ISCOMPLEX&&DATAIN_ISCOMPLEX
            COEF_WORDLENGTH=CoefDT.WordLength+1;
        end

        coefFIType=fi(0,COEF_SIGNED,COEF_WORDLENGTH,-COEF_FRACTIONLENGTH,'OverflowAction','Saturate','RoundingMethod','Nearest');



        if NoOfTaps==1
            CoefOut(1)=FilterImpl.addSignal2('Type',pir_fixpt_t(COEF_SIGNED,COEF_WORDLENGTH,COEF_FRACTIONLENGTH),'Name','CoefOut');
            CoefOut(1).SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(NoOfTaps);
            hAF.addBaseType(pir_fixpt_t(COEF_SIGNED,COEF_WORDLENGTH,COEF_FRACTIONLENGTH));
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            CoefOut(1)=FilterImpl.addSignal2('Type',dType_array,'Name','CoefOut');
            CoefOut(1).SimulinkRate=dataRate;
        end
        if COEF_ISCOMPLEX
            if DATAIN_ISCOMPLEX
                coefficientsP=cast(real(coefficients)+imag(coefficients),'like',coefFIType);
                coefficientsS=cast(real(coefficients)-imag(coefficients),'like',coefFIType);
                coefficientsI=cast(imag(coefficients),'like',coefFIType);
            else
                coefficientsR=cast(real(coefficients),'like',coefFIType);
                coefficientsI=cast(imag(coefficients),'like',coefFIType);
            end
        end

    end
    blockInfo.FilterLength=NoOfTaps;
    blockInfo.COEF_WORDLENGTH=COEF_WORDLENGTH;
    blockInfo.COEF_FRACTIONLENGTH=COEF_FRACTIONLENGTH;
    blockInfo.COEF_SIGNED=COEF_SIGNED;



    for inputIndex=1:DATAIN_VECSIZE
        din_re(inputIndex)=FilterImpl.addSignal2('Type',din_type,'Name',['din_',int2str(inputIndex),'_re']);
        din_re(inputIndex).SimulinkRate=dataRate;
        dout_re(inputIndex)=FilterImpl.addSignal2('Type',dout_type,'Name',['dout_',int2str(inputIndex),'_re']);
        dout_re(inputIndex).SimulinkRate=dataRate;
        if DATAIN_ISCOMPLEX
            din_im(inputIndex)=FilterImpl.addSignal2('Type',din_type,'Name',['din_',int2str(inputIndex),'_im']);
            din_im(inputIndex).SimulinkRate=dataRate;
        end
        if DATAOUT_ISCOMPLEX
            dout_im(inputIndex)=FilterImpl.addSignal2('Type',dout_type,'Name',['dout_',int2str(inputIndex),'_im']);
            dout_im(inputIndex).SimulinkRate=dataRate;
        end

        if DATAIN_ISCOMPLEX
            dType_cmplx=hdlcoder.tp_complex(din_type);
            din_cast=FilterImpl.addSignal2('Type',dType_cmplx,'Name','din_cast');
        else
            din_cast=FilterImpl.addSignal2('Type',din_type,'Name','din_cast');
        end
        din_cast.SimulinkRate=dataRate;
        if DATAIN_VECSIZE==1
            pirelab.getDTCComp(FilterImpl,dataIn,din_cast);
        else
            pirelab.getDTCComp(FilterImpl,dataIn.split.PirOutputSignals(inputIndex),din_cast);
        end
        if DATAIN_ISCOMPLEX
            pirelab.getComplex2RealImag(FilterImpl,din_cast,[din_re(inputIndex),din_im(inputIndex)],'Real and Imag');
        else
            din_re(inputIndex)=din_cast;
        end
    end



    for inputIndex=1:DATAIN_VECSIZE
        dinReg_re(inputIndex)=FilterImpl.addSignal2('Type',din_type,'Name',['dinReg_',int2str(inputIndex-1),'_re']);%#ok<*AGROW>
        dinReg_re(inputIndex).SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledResettableComp(FilterImpl,din_re(inputIndex),dinReg_re(inputIndex),validIn,syncReset,1);
        if DATAIN_ISCOMPLEX
            dinReg_im(inputIndex)=FilterImpl.addSignal2('Type',din_type,'Name',['dinReg_',int2str(inputIndex-1),'_im']);
            dinReg_im(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,din_im(inputIndex),dinReg_im(inputIndex),validIn,syncReset,1);
        elseif COEF_ISCOMPLEX
            dinReg_im(inputIndex)=FilterImpl.addSignal2('Type',din_type,'Name',['dinReg_',int2str(inputIndex-1),'_im']);
            dinReg_im(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,din_re(inputIndex),dinReg_im(inputIndex),validIn,syncReset,1);
        end
    end
    dinRegVld=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','dinRegVld');
    dinRegVld.SimulinkRate=dataRate;
    pirelab.getIntDelayEnabledResettableComp(FilterImpl,validIn,dinRegVld,'',syncReset,1);
    if DATAIN_ISCOMPLEX&&COEF_ISCOMPLEX
        DATAIN_WORDLENGTH=DATAIN_WORDLENGTH+1;
        din_typeX=pir_fixpt_t(DATAIN_SIGN,DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH);
    else
        din_typeX=din_type;
    end
    for inputIndex=1:DATAIN_VECSIZE
        dinReg2Vld=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','dinReg2Vld');
        dinReg2Vld.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledResettableComp(FilterImpl,dinRegVld,dinReg2Vld,'',syncReset,1);
        if DATAIN_ISCOMPLEX&&COEF_ISCOMPLEX



            dinReg_cast_re(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg_cast_',int2str(inputIndex-1),'_re']);
            dinReg_cast_re(inputIndex).SimulinkRate=dataRate;
            pirelab.getDTCComp(FilterImpl,dinReg_re(inputIndex),dinReg_cast_re(inputIndex));
            dinReg2_re(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg2_',int2str(inputIndex-1),'_re']);
            dinReg2_re(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,dinReg_cast_re(inputIndex),dinReg2_re(inputIndex),dinRegVld,syncReset,1);

            dinReg_cast_im(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg2_cast_',int2str(inputIndex-1),'_im']);
            dinReg_cast_im(inputIndex).SimulinkRate=dataRate;
            pirelab.getDTCComp(FilterImpl,dinReg_im(inputIndex),dinReg_cast_im(inputIndex));
            dinReg2_im(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg2_',int2str(inputIndex-1),'_im']);
            dinReg2_im(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,dinReg_cast_im(inputIndex),dinReg2_im(inputIndex),dinRegVld,syncReset,1);

            dinRealPImag(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinRealPImag_',int2str(inputIndex-1)]);
            dinRealPImag(inputIndex).SimulinkRate=dataRate;
            pirelab.getAddComp(FilterImpl,[dinReg_re(inputIndex),dinReg_im(inputIndex)],dinRealPImag(inputIndex));
            dinReg2_P(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg2_',int2str(inputIndex-1),'_P']);
            dinReg2_P(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,dinRealPImag(inputIndex),dinReg2_P(inputIndex),dinRegVld,syncReset,1);
        elseif DATAIN_ISCOMPLEX||COEF_ISCOMPLEX
            dinReg2_re(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg2_',int2str(inputIndex-1),'_re']);
            dinReg2_re(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,dinReg_re(inputIndex),dinReg2_re(inputIndex),dinRegVld,syncReset,1);
            dinReg2_im(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg2_',int2str(inputIndex-1),'_im']);
            dinReg2_im(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,dinReg_im(inputIndex),dinReg2_im(inputIndex),dinRegVld,syncReset,1);
        else
            dinReg2_re(inputIndex)=FilterImpl.addSignal2('Type',din_typeX,'Name',['dinReg2_',int2str(inputIndex-1),'_re']);
            dinReg2_re(inputIndex).SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FilterImpl,dinReg_re(inputIndex),dinReg2_re(inputIndex),dinRegVld,syncReset,1);
        end
    end




    CMPLXCMPLXFILTER=DATAIN_ISCOMPLEX&&COEF_ISCOMPLEX;
    FULLPRECISION=false;
    if CMPLXCMPLXFILTER
        FULLPRECISION=true;
        [OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,blockInfo]=getTargetSpecificDT(this,blockInfo);
        subfilter_type=pir_fixpt_t(DATAOUT_SIGN,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH);

        for inputIndex=1:DATAIN_VECSIZE
            dout_re(inputIndex)=FilterImpl.addSignal2('Type',subfilter_type,'Name',['dout_',int2str(inputIndex),'_re']);
            dout_re(inputIndex).SimulinkRate=dataRate;
            if DATAOUT_ISCOMPLEX
                dout_im(inputIndex)=FilterImpl.addSignal2('Type',subfilter_type,'Name',['dout_',int2str(inputIndex),'_im']);
                dout_im(inputIndex).SimulinkRate=dataRate;
            end
        end
    end

    doutVld=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','doutVld');
    doutVld.SimulinkRate=dataRate;


    [coeffProtoType,zeroOpt,singleDecl]=getCoeffProtoType(this,blockInfo.FilterCoefficient,DATAIN_VECSIZE);
    if singleDecl
        subFilter=this.elabSubFilter(FilterImpl,dataRate,blockInfo,...
        dinReg2_re(1),CoefOut(1),dinRegVld,syncReset,dout_re(1),doutVld,...
        FOLDINGFACTOR,...
        DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH,...
        COEF_WORDLENGTH,COEF_FRACTIONLENGTH,FULLPRECISION,...
        coeffProtoType,zeroOpt);
    end

    for inputIndex=1:DATAIN_VECSIZE
        if~singleDecl
            subFilter=this.elabSubFilter(FilterImpl,dataRate,blockInfo,...
            dinReg2_re(inputIndex),CoefOut(1),dinRegVld,syncReset,dout_re(inputIndex),doutVld,...
            FOLDINGFACTOR,...
            DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH,...
            COEF_WORDLENGTH,COEF_FRACTIONLENGTH,FULLPRECISION,...
            coeffProtoType{inputIndex},zeroOpt(inputIndex));
        end
        if COEF_ISCOMPLEX
            if DATAIN_ISCOMPLEX
                CoefOutP(inputIndex)=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefOutP');
                CoefOutP(inputIndex).SimulinkRate=dataRate;
                CoefOutS(inputIndex)=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefOutS');
                CoefOutS(inputIndex).SimulinkRate=dataRate;
                CoefOutI(inputIndex)=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefOutI');
                CoefOutI(inputIndex).SimulinkRate=dataRate;
            else
                CoefOutR(inputIndex)=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefOutR');
                CoefOutR(inputIndex).SimulinkRate=dataRate;
                CoefOutI(inputIndex)=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefOutI');
                CoefOutI(inputIndex).SimulinkRate=dataRate;
            end
        else
            CoefOut(inputIndex)=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefOut');
            CoefOut(inputIndex).SimulinkRate=dataRate;
        end




        if strcmpi(blockInfo.FilterCoefficientSource,'Property')
            if COEF_ISCOMPLEX
                if DATAIN_ISCOMPLEX
                    CoefTableP=this.elabCoefTable(FilterImpl,blockInfo,dataRate,DATAIN_VECSIZE,inputIndex,coefficientsP,...
                    validIn,syncReset,CoefOutP(inputIndex),...
                    COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
                    pirelab.instantiateNetwork(FilterImpl,CoefTableP,...
                    [validIn,syncReset],...
                    CoefOutP(inputIndex),['CoefTableP_',int2str(inputIndex)]);
                    CoefTableS=this.elabCoefTable(FilterImpl,blockInfo,dataRate,DATAIN_VECSIZE,inputIndex,coefficientsS,...
                    validIn,syncReset,CoefOutS(inputIndex),...
                    COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
                    pirelab.instantiateNetwork(FilterImpl,CoefTableS,...
                    [validIn,syncReset],...
                    CoefOutS(inputIndex),['CoefTableS_',int2str(inputIndex)]);
                    CoefTableI=this.elabCoefTable(FilterImpl,blockInfo,dataRate,DATAIN_VECSIZE,inputIndex,coefficientsI,...
                    validIn,syncReset,CoefOutI(inputIndex),...
                    COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
                    pirelab.instantiateNetwork(FilterImpl,CoefTableI,...
                    [validIn,syncReset],...
                    CoefOutI(inputIndex),['CoefTableI_',int2str(inputIndex)]);
                else
                    CoefTableR=this.elabCoefTable(FilterImpl,blockInfo,dataRate,DATAIN_VECSIZE,inputIndex,coefficientsR,...
                    validIn,syncReset,CoefOutR(inputIndex),...
                    COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
                    pirelab.instantiateNetwork(FilterImpl,CoefTableR,...
                    [validIn,syncReset],...
                    CoefOutR(inputIndex),['CoefTableR_',int2str(inputIndex)]);
                    CoefTableI=this.elabCoefTable(FilterImpl,blockInfo,dataRate,DATAIN_VECSIZE,inputIndex,coefficientsI,...
                    validIn,syncReset,CoefOutI(inputIndex),...
                    COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
                    pirelab.instantiateNetwork(FilterImpl,CoefTableI,...
                    [validIn,syncReset],...
                    CoefOutI(inputIndex),['CoefTableI_',int2str(inputIndex)]);
                end
            else
                CoefTable=this.elabCoefTable(FilterImpl,blockInfo,dataRate,DATAIN_VECSIZE,inputIndex,coefficients,...
                validIn,syncReset,CoefOut(inputIndex),...
                COEF_WORDLENGTH,COEF_FRACTIONLENGTH);
                pirelab.instantiateNetwork(FilterImpl,CoefTable,...
                [validIn,syncReset],...
                CoefOut(inputIndex),['CoefTable_',int2str(inputIndex)]);
            end
        else
            if COEF_ISCOMPLEX
                [~,isSymmetry]=getCoefficientsSymmetry(this,'',blockInfo,DATAOUT_WORDLENGTH,DATAOUT_FRACTIONLENGTH,FOLDINGFACTOR);
                isSymmetry=isSymmetry&&blockInfo.SymmetryOptimization;
                if DATAIN_ISCOMPLEX
                    CoefReg1_re=FilterImpl.addSignal2('Type',coeffIn_re(inputIndex).Type,'Name','CoefReg1_re');
                    CoefReg1_re.SimulinkRate=dataRate;
                    CoefReg1_im=FilterImpl.addSignal2('Type',coeffIn_im(inputIndex).Type,'Name','CoefReg1_im');
                    CoefReg1_im.SimulinkRate=dataRate;
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,coeffIn_re(inputIndex),CoefReg1_re,validIn,syncReset,1);
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,coeffIn_im(inputIndex),CoefReg1_im,validIn,syncReset,1);
                    CoefP=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefP');
                    CoefP.SimulinkRate=dataRate;
                    CoefS=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefS');
                    CoefS.SimulinkRate=dataRate;
                    CoefI=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefI');
                    CoefI.SimulinkRate=dataRate;
                    pirelab.getSubComp(FilterImpl,[CoefReg1_re,CoefReg1_im],CoefS);
                    pirelab.getAddComp(FilterImpl,[CoefReg1_re,CoefReg1_im],CoefP);
                    pirelab.getDTCComp(FilterImpl,CoefReg1_im,CoefI);
                    CoefReg1_P=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg1_P');
                    CoefReg1_P.SimulinkRate=dataRate;
                    CoefReg1_M=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg1_M');
                    CoefReg1_M.SimulinkRate=dataRate;
                    CoefReg1_I=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg1_I');
                    CoefReg1_I.SimulinkRate=dataRate;
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefP,CoefReg1_P,dinRegVld,syncReset,1);
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefS,CoefReg1_M,dinRegVld,syncReset,1);
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefI,CoefReg1_I,dinRegVld,syncReset,1);
                    if isSymmetry&&strcmpi(blockInfo.FilterStructure,'Direct form systolic')
                        pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg1_P,CoefOutP(inputIndex),dinReg2Vld,syncReset,1);
                        pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg1_M,CoefOutS(inputIndex),dinReg2Vld,syncReset,1);
                        pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg1_I,CoefOutI(inputIndex),dinReg2Vld,syncReset,1);
                    else
                        pirelab.getWireComp(FilterImpl,CoefReg1_P,CoefOutP(inputIndex));
                        pirelab.getWireComp(FilterImpl,CoefReg1_M,CoefOutS(inputIndex));
                        pirelab.getWireComp(FilterImpl,CoefReg1_I,CoefOutI(inputIndex));
                    end
                else
                    CoefReg1_re=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg1_re');
                    CoefReg1_re.SimulinkRate=dataRate;
                    CoefReg2_re=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg2_re');
                    CoefReg2_re.SimulinkRate=dataRate;
                    CoefReg1_im=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg1_im');
                    CoefReg1_im.SimulinkRate=dataRate;
                    CoefReg2_im=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg2_im');
                    CoefReg2_im.SimulinkRate=dataRate;
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,coeffIn_re(inputIndex),CoefReg1_re,validIn,syncReset,1);
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg1_re,CoefReg2_re,dinRegVld,syncReset,1);
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,coeffIn_im(inputIndex),CoefReg1_im,validIn,syncReset,1);
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg1_im,CoefReg2_im,dinRegVld,syncReset,1);
                    if isSymmetry&&strcmpi(blockInfo.FilterStructure,'Direct form systolic')
                        pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg2_re,CoefOutR(inputIndex),dinReg2Vld,syncReset,1);
                        pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg2_im,CoefOutI(inputIndex),dinReg2Vld,syncReset,1);
                    else
                        pirelab.getWireComp(FilterImpl,CoefReg2_re,CoefOutR(inputIndex));
                        pirelab.getWireComp(FilterImpl,CoefReg2_im,CoefOutI(inputIndex));
                    end
                end
            else

                [~,isSymmetry]=getCoefficientsSymmetry(this,'',blockInfo,DATAOUT_WORDLENGTH,DATAOUT_FRACTIONLENGTH,FOLDINGFACTOR);
                isSymmetry=isSymmetry&&blockInfo.SymmetryOptimization;
                CoefReg1=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg1');
                CoefReg1.SimulinkRate=dataRate;
                CoefReg2=FilterImpl.addSignal2('Type',CoefOut(1).Type,'Name','CoefReg2');
                CoefReg2.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(FilterImpl,coeffIn_signed(inputIndex),CoefReg1,validIn,syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg1,CoefReg2,dinRegVld,syncReset,1);
                if isSymmetry&&strcmpi(blockInfo.FilterStructure,'Direct form systolic')
                    pirelab.getIntDelayEnabledResettableComp(FilterImpl,CoefReg2,CoefOut(inputIndex),dinReg2Vld,syncReset,1);
                else
                    pirelab.getWireComp(FilterImpl,CoefReg2,CoefOut(inputIndex));
                end
            end
        end


        if COEF_ISCOMPLEX
            if DATAIN_ISCOMPLEX
                dout_P(inputIndex)=FilterImpl.addSignal2('Type',subfilter_type,'Name',['dout_',int2str(inputIndex),'_P']);
                dout_P(inputIndex).SimulinkRate=dataRate;
                dout_M(inputIndex)=FilterImpl.addSignal2('Type',subfilter_type,'Name',['dout_',int2str(inputIndex),'_M']);
                dout_M(inputIndex).SimulinkRate=dataRate;
                dout_I(inputIndex)=FilterImpl.addSignal2('Type',subfilter_type,'Name',['dout_',int2str(inputIndex),'_I']);
                dout_I(inputIndex).SimulinkRate=dataRate;
                doutVld_M=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','doutVld_M');
                doutVld_M.SimulinkRate=dataRate;
                doutVld_I=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','doutVld_I');
                doutVld_I.SimulinkRate=dataRate;
                pirelab.instantiateNetwork(FilterImpl,subFilter,...
                [dinReg2_re(inputIndex),CoefOutP(inputIndex),dinReg2Vld,syncReset],...
                [dout_P(inputIndex),doutVld],['subFilter_',int2str(inputIndex),'_reP']);
                pirelab.instantiateNetwork(FilterImpl,subFilter,...
                [dinReg2_im(inputIndex),CoefOutS(inputIndex),dinReg2Vld,syncReset],...
                [dout_M(inputIndex),doutVld_M],['subFilter_',int2str(inputIndex),'_reS']);
                pirelab.instantiateNetwork(FilterImpl,subFilter,...
                [dinReg2_P(inputIndex),CoefOutI(inputIndex),dinReg2Vld,syncReset],...
                [dout_I(inputIndex),doutVld_I],['subFilter_',int2str(inputIndex),'_im']);
                dout_FP_type=pir_fixpt_t(DATAOUT_SIGN,dout_P(inputIndex).Type.WordLength+1,dout_P(inputIndex).Type.FractionLength);

                dout_r(inputIndex)=FilterImpl.addSignal2('Type',dout_FP_type,'Name',['dout_',int2str(inputIndex),'_r']);
                dout_r(inputIndex).SimulinkRate=dataRate;
                dout_i(inputIndex)=FilterImpl.addSignal2('Type',dout_FP_type,'Name',['dout_',int2str(inputIndex),'_i']);
                dout_i(inputIndex).SimulinkRate=dataRate;
                dout_cast_r(inputIndex)=FilterImpl.addSignal2('Type',dout_type,'Name',['dout_',int2str(inputIndex),'_cast_r']);
                dout_cast_r(inputIndex).SimulinkRate=dataRate;
                dout_cast_i(inputIndex)=FilterImpl.addSignal2('Type',dout_type,'Name',['dout_',int2str(inputIndex),'_cast_i']);
                dout_cast_i(inputIndex).SimulinkRate=dataRate;
                dout_re(inputIndex)=FilterImpl.addSignal2('Type',dout_type,'Name',['dout_',int2str(inputIndex),'_re']);
                dout_re(inputIndex).SimulinkRate=dataRate;
                dout_im(inputIndex)=FilterImpl.addSignal2('Type',dout_type,'Name',['dout_',int2str(inputIndex),'_im']);
                dout_im(inputIndex).SimulinkRate=dataRate;
                doutVldReg=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','doutVldReg');
                doutVldReg.SimulinkRate=dataRate;
                pirelab.getSubComp(FilterImpl,[dout_P(inputIndex),dout_I(inputIndex)],dout_r(inputIndex));
                pirelab.getAddComp(FilterImpl,[dout_M(inputIndex),dout_I(inputIndex)],dout_i(inputIndex));
                pirelab.getDTCComp(FilterImpl,dout_r(inputIndex),dout_cast_r(inputIndex),blockInfo.RoundingMethod,blockInfo.OverflowAction);
                pirelab.getDTCComp(FilterImpl,dout_i(inputIndex),dout_cast_i(inputIndex),blockInfo.RoundingMethod,blockInfo.OverflowAction);
                pirelab.getIntDelayEnabledResettableComp(FilterImpl,dout_cast_r(inputIndex),dout_re(inputIndex),'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(FilterImpl,dout_cast_i(inputIndex),dout_im(inputIndex),'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(FilterImpl,doutVld,doutVldReg,'',syncReset,1);
                doutVld=doutVldReg;
            else
                doutVld_i=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','doutVld_i');
                doutVld_i.SimulinkRate=dataRate;
                pirelab.instantiateNetwork(FilterImpl,subFilter,...
                [dinReg2_re(inputIndex),CoefOutR(inputIndex),dinReg2Vld,syncReset],...
                [dout_re(inputIndex),doutVld],['subFilter_',int2str(inputIndex),'_re']);
                pirelab.instantiateNetwork(FilterImpl,subFilter,...
                [dinReg2_im(inputIndex),CoefOutI(inputIndex),dinReg2Vld,syncReset],...
                [dout_im(inputIndex),doutVld_i],['subFilter_',int2str(inputIndex),'_im']);
            end
        else
            pirelab.instantiateNetwork(FilterImpl,subFilter,...
            [dinReg2_re(inputIndex),CoefOut(inputIndex),dinReg2Vld,syncReset],...
            [dout_re(inputIndex),doutVld],['subFilter_',int2str(inputIndex),'_re']);
            if DATAIN_ISCOMPLEX
                doutVld_i=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','doutVld');
                doutVld_i.SimulinkRate=dataRate;
                pirelab.instantiateNetwork(FilterImpl,subFilter,...
                [dinReg2_im(inputIndex),CoefOut(inputIndex),dinReg2Vld,syncReset],...
                [dout_im(inputIndex),doutVld_i],['subFilter_',int2str(inputIndex),'_im']);
            end
        end
        if inputIndex<DATAIN_VECSIZE
            doutVld=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','doutVld');
            doutVld.SimulinkRate=dataRate;
        end
    end





    if DATAOUT_ISCOMPLEX
        if DATAIN_VECSIZE==1
            dout_cmplx=FilterImpl.addSignal2('Type',outsignals(1).Type,'Name','dout_cmplx');
            dout_cmplx.SimulinkRate=dataRate;
            pirelab.getRealImag2Complex(FilterImpl,[dout_re,dout_im],dout_cmplx);
            pirelab.getWireComp(FilterImpl,dout_cmplx,outsignals(1));
        else
            for inIndex=1:DATAIN_VECSIZE
                dout_cmplx(inIndex)=FilterImpl.addSignal2('Type',outsignals(1).Type.BaseType,'Name',['dout_cmplx_',int2str(inIndex)]);
                dout_cmplx(inIndex).SimulinkRate=dataRate;
                pirelab.getRealImag2Complex(FilterImpl,[dout_re(inIndex),dout_im(inIndex)],dout_cmplx(inIndex));
            end
            pirelab.getMuxComp(FilterImpl,dout_cmplx,outsignals(1));
        end
    else
        pirelab.getMuxComp(FilterImpl,dout_re,outsignals(1));
    end
    pirelab.getWireComp(FilterImpl,doutVld,outsignals(2));






    function[coeffProtoType,zeroOpt,singleDecl]=getCoeffProtoType(this,coeff,vecSize)



        [row,~]=size(coeff);
        partitionSize=row/vecSize;
        for loop2=1:vecSize
            coeffPartitions{loop2}=coeff(1+(loop2-1)*partitionSize:loop2*(partitionSize),:);
        end



        zeroOptV(1)=true;
        for loop1=1:vecSize




            coeffPart=coeffPartitions{loop1};
            [row,~]=size(coeffPart);



            for loop2=1:row
                nonZeroCoeffIdx{loop2}=find(coeffPart(loop2,:));
                if length(coeffPart(loop2,:))==length(nonZeroCoeffIdx{loop2})
                    hasZeroCoef(loop2)=0;
                else
                    hasZeroCoef(loop2)=1;
                end
            end


            if~any(hasZeroCoef)
                groupProtoType{loop1}=coeffPart(1,:);
                zeroOptV(loop1)=false;
            elseif all(hasZeroCoef)
                if length(hasZeroCoef)==1
                    groupProtoType{loop1}=coeffPart(1,:);
                    zeroOptV(loop1)=true;
                else
                    refIdx=nonZeroCoeffIdx{1};
                    groupProtoType{loop1}=coeffPart(1,:);
                    zeroOptV(loop1)=true;
                    for loop2=2:row
                        if length(nonZeroCoeffIdx{loop2})~=length(refIdx)
                            zeroOptV(loop1)=false;
                            break;
                        else
                            if prod(refIdx==nonZeroCoeffIdx{loop2})==0
                                zeroOptV(loop1)=false;
                                break;
                            end
                        end
                    end
                end
            else
                idx=find(hasZeroCoef==0);
                groupProtoType{loop1}=coeffPart(idx(1),:);
                zeroOptV(loop1)=false;
            end
        end


        if~any(zeroOptV)
            singleDecl=true;
            coeffProtoType=groupProtoType{1};
            zeroOpt=zeroOptV(1);
        elseif all(zeroOptV)

            singleDecl=true;
            coeffProtoType=groupProtoType{1};
            zeroOpt=zeroOptV(1);
            refIdx=find(groupProtoType{1});
            for loop=2:length(groupProtoType)
                tmp=find(groupProtoType{loop});
                if length(tmp)~=length(refIdx)
                    singleDecl=false;
                    coeffProtoType=groupProtoType;
                    zeroOpt=zeroOptV;
                    break;
                else
                    if prod(refIdx==find(groupProtoType{loop}))==0
                        singleDecl=false;
                        coeffProtoType=groupProtoType;
                        zeroOpt=zeroOptV;
                        break;
                    end
                end
            end
        else
            singleDecl=false;
            coeffProtoType=groupProtoType;
            zeroOpt=zeroOptV;
        end











