function symDemodQPSKVector=elabQPSKVectorSymDemodNet(~,topNet,blockInfo,rate,inpWL,inpFL)

    if inpFL<-14
        addIncBits=0;
    else
        addIncBits=14+inpFL;
    end

    pirTyp2=pir_boolean_t;
    pirTyp3=pir_sfixpt_t(inpWL+4,inpFL);
    pirTyp4=pir_sfixpt_t(inpWL+5,inpFL);
    pirTyp6=pir_sfixpt_t(16,-14);
    pirTyp7=pir_sfixpt_t(2*(inpWL+4),2*inpFL);
    pirTyp9=pir_sfixpt_t(inpWL+5+addIncBits,min(inpFL,-14));
    pirTyp8=pir_sfixpt_t(inpWL+16,inpFL-14);
    pirTyp5=pir_sfixpt_t(inpWL+17,inpFL-14);
    pirTyp1=pir_sfixpt_t(inpWL,inpFL);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(1,inpWL+4,-inpFL);
    nt3=numerictype(1,16,14);
    nt4=numerictype(1,2*(inpWL+4),-2*inpFL);
    nt5=numerictype(1,inpWL+16,-inpFL+14);
    nt6=numerictype(1,inpWL+17,-inpFL+14);
    nt2=numerictype(1,inpWL,-inpFL);

    inportNameQPSK={'dataIn','validIn'};
    controlType=pir_ufixpt_t(1,0);
    inType=pir_complex_t(pir_sfixpt_t(inpWL,inpFL));
    inTypeQPSK=[inType,controlType];
    inDataRateQPSK=[rate,rate];

    outportNameQPSK={'dataOut','validOut'};
    outTypeQPSK=[pirelab.createPirArrayType(pirTyp3,[2,0]),controlType];

    symDemodQPSKVector=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','symDemodQPSKVector',...
    'InportNames',inportNameQPSK,...
    'InportTypes',inTypeQPSK,...
    'InportRates',inDataRateQPSK,...
    'OutportNames',outportNameQPSK,...
    'OutportTypes',outTypeQPSK...
    );


    dataIn_s0=symDemodQPSKVector.PirInputSignals(1);
    validIn_s1=symDemodQPSKVector.PirInputSignals(2);

    dataOut=symDemodQPSKVector.PirOutputSignals(1);
    validOut=symDemodQPSKVector.PirOutputSignals(2);
    slRate1=rate;


    DataTypeConversion_out1_s13=addSignal(symDemodQPSKVector,'Data Type Conversion_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    delayMatch3_out1_s88=addSignal(symDemodQPSKVector,'delayMatch3_out1',pirTyp2,slRate1);

    Abs_out1_s2=addSignal(symDemodQPSKVector,'Abs_out1',pirTyp3,slRate1);
    Abs1_out1_s3=addSignal(symDemodQPSKVector,'Abs1_out1',pirTyp3,slRate1);
    Add_out1_s4=addSignal(symDemodQPSKVector,'Add_out1',pirelab.createPirArrayType(pirTyp4,[2,0]),slRate1);
    Add1_out1_s5=addSignal(symDemodQPSKVector,'Add1_out1',pirelab.createPirArrayType(pirTyp4,[2,0]),slRate1);
    Add2_out1_s6=addSignal(symDemodQPSKVector,'Add2_out1',pirTyp5,slRate1);
    Add3_out1_s7=addSignal(symDemodQPSKVector,'Add3_out1',pirTyp5,slRate1);
    CompareToConstant_out1_s8=addSignal(symDemodQPSKVector,'Compare To Constant_out1',pirTyp2,slRate1);
    CompareToConstant1_out1_s9=addSignal(symDemodQPSKVector,'Compare To Constant1_out1',pirTyp2,slRate1);
    ComplexToReal_Imag3_out1_s10=addSignal(symDemodQPSKVector,'Complex to Real-Imag3_out1',pirTyp1,slRate1);
    ComplexToReal_Imag3_out2_s11=addSignal(symDemodQPSKVector,'Complex to Real-Imag3_out2',pirTyp1,slRate1);
    Constant5_out1_s12=addSignal(symDemodQPSKVector,'Constant5_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion1_out1_s14=addSignal(symDemodQPSKVector,'Data Type Conversion1_out1',pirTyp3,slRate1);
    DataTypeConversion10_out1_s15=addSignal(symDemodQPSKVector,'Data Type Conversion10_out1',pirTyp3,slRate1);
    DataTypeConversion11_out1_s16=addSignal(symDemodQPSKVector,'Data Type Conversion11_out1',pirTyp3,slRate1);
    DataTypeConversion12_out1_s17=addSignal(symDemodQPSKVector,'Data Type Conversion12_out1',pirTyp3,slRate1);
    DataTypeConversion13_out1_s18=addSignal(symDemodQPSKVector,'Data Type Conversion13_out1',pirTyp3,slRate1);
    DataTypeConversion14_out1_s19=addSignal(symDemodQPSKVector,'Data Type Conversion14_out1',pirTyp3,slRate1);
    DataTypeConversion15_out1_s20=addSignal(symDemodQPSKVector,'Data Type Conversion15_out1',pirTyp3,slRate1);
    DataTypeConversion2_out1_s21=addSignal(symDemodQPSKVector,'Data Type Conversion2_out1',pirTyp3,slRate1);
    DataTypeConversion3_out1_s22=addSignal(symDemodQPSKVector,'Data Type Conversion3_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion4_out1_s23=addSignal(symDemodQPSKVector,'Data Type Conversion4_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion5_out1_s24=addSignal(symDemodQPSKVector,'Data Type Conversion5_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion6_out1_s25=addSignal(symDemodQPSKVector,'Data Type Conversion6_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion7_out1_s26=addSignal(symDemodQPSKVector,'Data Type Conversion7_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion8_out1_s27=addSignal(symDemodQPSKVector,'Data Type Conversion8_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion9_out1_s28=addSignal(symDemodQPSKVector,'Data Type Conversion9_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    DataTypeConversion9_out1_0_wire_out1_s29=addSignal(symDemodQPSKVector,'Data Type Conversion9_out1_0_wire_out1',pirTyp3,slRate1);
    DataTypeConversion9_out1_1_wire_out1_s30=addSignal(symDemodQPSKVector,'Data Type Conversion9_out1_1_wire_out1',pirTyp3,slRate1);
    HwModeRegister_out1_s31=addSignal(symDemodQPSKVector,'HwModeRegister_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister1_out1_s32=addSignal(symDemodQPSKVector,'HwModeRegister1_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister10_out1_s33=addSignal(symDemodQPSKVector,'HwModeRegister10_out1',pirTyp1,slRate1);
    HwModeRegister11_out1_s34=addSignal(symDemodQPSKVector,'HwModeRegister11_out1',pirTyp6,slRate1);
    HwModeRegister12_out1_s35=addSignal(symDemodQPSKVector,'HwModeRegister12_out1',pirTyp1,slRate1);
    HwModeRegister13_out1_s36=addSignal(symDemodQPSKVector,'HwModeRegister13_out1',pirTyp6,slRate1);
    HwModeRegister14_out1_s37=addSignal(symDemodQPSKVector,'HwModeRegister14_out1',pirTyp6,slRate1);
    HwModeRegister15_out1_s38=addSignal(symDemodQPSKVector,'HwModeRegister15_out1',pirTyp1,slRate1);
    HwModeRegister2_out1_s39=addSignal(symDemodQPSKVector,'HwModeRegister2_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister3_out1_s40=addSignal(symDemodQPSKVector,'HwModeRegister3_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister4_out1_s41=addSignal(symDemodQPSKVector,'HwModeRegister4_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister5_out1_s42=addSignal(symDemodQPSKVector,'HwModeRegister5_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister6_out1_s43=addSignal(symDemodQPSKVector,'HwModeRegister6_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister7_out1_s44=addSignal(symDemodQPSKVector,'HwModeRegister7_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    HwModeRegister8_out1_s45=addSignal(symDemodQPSKVector,'HwModeRegister8_out1',pirTyp6,slRate1);
    HwModeRegister9_out1_s46=addSignal(symDemodQPSKVector,'HwModeRegister9_out1',pirTyp1,slRate1);
    PSKSymbolConverterBlock_out2_out1_s47=addSignal(symDemodQPSKVector,'PSKSymbolConverterBlock_out2_out1',pirTyp3,slRate1);
    PipelineRegister_out1_s48=addSignal(symDemodQPSKVector,'PipelineRegister_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    PipelineRegister1_out1_s49=addSignal(symDemodQPSKVector,'PipelineRegister1_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    PipelineRegister2_out1_s50=addSignal(symDemodQPSKVector,'PipelineRegister2_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    PipelineRegister3_out1_s51=addSignal(symDemodQPSKVector,'PipelineRegister3_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    PipelineRegister4_out1_s52=addSignal(symDemodQPSKVector,'PipelineRegister4_out1',pirTyp8,slRate1);
    PipelineRegister5_out1_s53=addSignal(symDemodQPSKVector,'PipelineRegister5_out1',pirTyp8,slRate1);
    PipelineRegister6_out1_s54=addSignal(symDemodQPSKVector,'PipelineRegister6_out1',pirTyp8,slRate1);
    PipelineRegister7_out1_s55=addSignal(symDemodQPSKVector,'PipelineRegister7_out1',pirTyp8,slRate1);
    PipelineRegister8_out1_s56=addSignal(symDemodQPSKVector,'PipelineRegister8_out1',pirTyp5,slRate1);
    PipelineRegister9_out1_s57=addSignal(symDemodQPSKVector,'PipelineRegister9_out1',pirTyp5,slRate1);
    Product_out1_s58=addSignal(symDemodQPSKVector,'Product_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    Product1_out1_s59=addSignal(symDemodQPSKVector,'Product1_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    Product2_out1_s60=addSignal(symDemodQPSKVector,'Product2_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    Product3_out1_s61=addSignal(symDemodQPSKVector,'Product3_out1',pirelab.createPirArrayType(pirTyp7,[2,0]),slRate1);
    Product4_out1_s62=addSignal(symDemodQPSKVector,'Product4_out1',pirTyp8,slRate1);
    Product5_out1_s63=addSignal(symDemodQPSKVector,'Product5_out1',pirTyp8,slRate1);
    Product6_out1_s64=addSignal(symDemodQPSKVector,'Product6_out1',pirTyp8,slRate1);
    Product7_out1_s65=addSignal(symDemodQPSKVector,'Product7_out1',pirTyp8,slRate1);
    Subtract1_out1_s66=addSignal(symDemodQPSKVector,'Subtract1_out1',pirTyp9,slRate1);
    Subtract2_out1_s67=addSignal(symDemodQPSKVector,'Subtract2_out1',pirTyp9,slRate1);
    Subtract3_out1_s68=addSignal(symDemodQPSKVector,'Subtract3_out1',pirTyp9,slRate1);
    Subtract4_out1_s69=addSignal(symDemodQPSKVector,'Subtract4_out1',pirelab.createPirArrayType(pirTyp4,[2,0]),slRate1);
    Subtract5_out1_s70=addSignal(symDemodQPSKVector,'Subtract5_out1',pirTyp9,slRate1);
    Subtract6_out1_s71=addSignal(symDemodQPSKVector,'Subtract6_out1',pirTyp9,slRate1);
    Subtract7_out1_s72=addSignal(symDemodQPSKVector,'Subtract7_out1',pirTyp9,slRate1);
    Switch10_out1_s73=addSignal(symDemodQPSKVector,'Switch10_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    Switch2_out1_s74=addSignal(symDemodQPSKVector,'Switch2_out1',pirTyp3,slRate1);
    Switch3_out1_s75=addSignal(symDemodQPSKVector,'Switch3_out1',pirTyp3,slRate1);
    UnaryMinus_out1_s76=addSignal(symDemodQPSKVector,'Unary Minus_out1',pirTyp3,slRate1);
    UnaryMinus1_out1_s77=addSignal(symDemodQPSKVector,'Unary Minus1_out1',pirTyp3,slRate1);
    concatenate_out1_s78=addSignal(symDemodQPSKVector,'concatenate_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    concatenate1_out1_s79=addSignal(symDemodQPSKVector,'concatenate1_out1',pirelab.createPirArrayType(pirTyp2,[2,0]),slRate1);
    concatenate2_out1_s80=addSignal(symDemodQPSKVector,'concatenate2_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    concatenate3_out1_s81=addSignal(symDemodQPSKVector,'concatenate3_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    concatenate4_out1_s82=addSignal(symDemodQPSKVector,'concatenate4_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    concatenate5_out1_s83=addSignal(symDemodQPSKVector,'concatenate5_out1',pirelab.createPirArrayType(pirTyp3,[2,0]),slRate1);
    cos_out1_s84=addSignal(symDemodQPSKVector,'cos_out1',pirTyp6,slRate1);
    delayMatch_out1_s85=addSignal(symDemodQPSKVector,'delayMatch_out1',pirTyp2,slRate1);
    delayMatch1_out1_s86=addSignal(symDemodQPSKVector,'delayMatch1_out1',pirTyp2,slRate1);
    delayMatch2_out1_s87=addSignal(symDemodQPSKVector,'delayMatch2_out1',pirTyp2,slRate1);
    lookUpTable11_out1_s89=addSignal(symDemodQPSKVector,'lookUpTable11_out1',pirTyp6,slRate1);
    lookUpTable12_out1_s90=addSignal(symDemodQPSKVector,'lookUpTable12_out1',pirTyp6,slRate1);
    lookUpTable21_out1_s91=addSignal(symDemodQPSKVector,'lookUpTable21_out1',pirTyp6,slRate1);
    lookUpTable22_out1_s92=addSignal(symDemodQPSKVector,'lookUpTable22_out1',pirTyp6,slRate1);
    lookUpTable31_out1_s93=addSignal(symDemodQPSKVector,'lookUpTable31_out1',pirTyp6,slRate1);
    lookUpTable32_out1_s94=addSignal(symDemodQPSKVector,'lookUpTable32_out1',pirTyp6,slRate1);
    pskMapVec_out1_s95=addSignal(symDemodQPSKVector,'pskMapVec_out1',pirTyp3,slRate1);
    sin_out1_s96=addSignal(symDemodQPSKVector,'sin_out1',pirTyp6,slRate1);
    t_out1_s97=addSignal(symDemodQPSKVector,'t_out1',pirTyp2,slRate1);
    t_out2_s98=addSignal(symDemodQPSKVector,'t_out2',pirTyp2,slRate1);
    t1_out1_s99=addSignal(symDemodQPSKVector,'t1_out1',pirTyp3,slRate1);
    t1_out2_s100=addSignal(symDemodQPSKVector,'t1_out2',pirTyp3,slRate1);
    validOut1_out1_s101=addSignal(symDemodQPSKVector,'validOut1_out1',pirTyp2,slRate1);
    concatenate1_out1_0_s107=addSignal(symDemodQPSKVector,'concatenate1_out1_0',pirTyp2,slRate1);
    concatenate1_out1_1_s108=addSignal(symDemodQPSKVector,'concatenate1_out1_1',pirTyp2,slRate1);
    DataTypeConversion9_out1_0_s109=addSignal(symDemodQPSKVector,'Data Type Conversion9_out1_0',pirTyp3,slRate1);
    DataTypeConversion9_out1_1_s110=addSignal(symDemodQPSKVector,'Data Type Conversion9_out1_1',pirTyp3,slRate1);


    pirelab.getConstComp(symDemodQPSKVector,...
    Constant5_out1_s12,...
    fi(0,nt1,fiMath1,'hex','000'),...
    'Constant5','on',1,'','','');


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate2_out1_s80,...
    HwModeRegister_out1_s31,...
    1,'HwModeRegister',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate2_out1_s80,...
    HwModeRegister1_out1_s32,...
    1,'HwModeRegister1',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    ComplexToReal_Imag3_out2_s11,...
    HwModeRegister10_out1_s33,...
    1,'HwModeRegister10',...
    fi(0,nt2,fiMath1,'hex','00'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    sin_out1_s96,...
    HwModeRegister11_out1_s34,...
    1,'HwModeRegister11',...
    fi(0,nt3,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    ComplexToReal_Imag3_out1_s10,...
    HwModeRegister12_out1_s35,...
    1,'HwModeRegister12',...
    fi(0,nt2,fiMath1,'hex','00'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    sin_out1_s96,...
    HwModeRegister13_out1_s36,...
    1,'HwModeRegister13',...
    fi(0,nt3,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    cos_out1_s84,...
    HwModeRegister14_out1_s37,...
    1,'HwModeRegister14',...
    fi(0,nt3,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    ComplexToReal_Imag3_out2_s11,...
    HwModeRegister15_out1_s38,...
    1,'HwModeRegister15',...
    fi(0,nt2,fiMath1,'hex','00'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate4_out1_s82,...
    HwModeRegister2_out1_s39,...
    1,'HwModeRegister2',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate4_out1_s82,...
    HwModeRegister3_out1_s40,...
    1,'HwModeRegister3',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate3_out1_s81,...
    HwModeRegister4_out1_s41,...
    1,'HwModeRegister4',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate3_out1_s81,...
    HwModeRegister5_out1_s42,...
    1,'HwModeRegister5',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate5_out1_s83,...
    HwModeRegister6_out1_s43,...
    1,'HwModeRegister6',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    concatenate5_out1_s83,...
    HwModeRegister7_out1_s44,...
    1,'HwModeRegister7',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    cos_out1_s84,...
    HwModeRegister8_out1_s45,...
    1,'HwModeRegister8',...
    fi(0,nt3,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    ComplexToReal_Imag3_out1_s10,...
    HwModeRegister9_out1_s46,...
    1,'HwModeRegister9',...
    fi(0,nt2,fiMath1,'hex','00'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product_out1_s58,...
    PipelineRegister_out1_s48,...
    1,'PipelineRegister',...
    fi(0,nt4,fiMath1,'hex','00000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product1_out1_s59,...
    PipelineRegister1_out1_s49,...
    1,'PipelineRegister1',...
    fi(0,nt4,fiMath1,'hex','00000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product2_out1_s60,...
    PipelineRegister2_out1_s50,...
    1,'PipelineRegister2',...
    fi(0,nt4,fiMath1,'hex','00000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product3_out1_s61,...
    PipelineRegister3_out1_s51,...
    1,'PipelineRegister3',...
    fi(0,nt4,fiMath1,'hex','00000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product4_out1_s62,...
    PipelineRegister4_out1_s52,...
    1,'PipelineRegister4',...
    fi(0,nt5,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product5_out1_s63,...
    PipelineRegister5_out1_s53,...
    1,'PipelineRegister5',...
    fi(0,nt5,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product6_out1_s64,...
    PipelineRegister6_out1_s54,...
    1,'PipelineRegister6',...
    fi(0,nt5,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Product7_out1_s65,...
    PipelineRegister7_out1_s55,...
    1,'PipelineRegister7',...
    fi(0,nt5,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Add2_out1_s6,...
    PipelineRegister8_out1_s56,...
    1,'PipelineRegister8',...
    fi(0,nt6,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    Add3_out1_s7,...
    PipelineRegister9_out1_s57,...
    1,'PipelineRegister9',...
    fi(0,nt6,fiMath1,'hex','000000'),...
    0,0,[],0,0);






    pirelab.getConstComp(symDemodQPSKVector,cos_out1_s84,blockInfo.LUTvalueReal);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    t_out2_s98,...
    delayMatch_out1_s85,...
    2,'delayMatch',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    t_out1_s97,...
    delayMatch1_out1_s86,...
    2,'delayMatch1',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    validOut1_out1_s101,...
    delayMatch2_out1_s87,...
    5,'delayMatch2',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodQPSKVector,...
    validOut1_out1_s101,...
    delayMatch3_out1_s88,...
    5,'delayMatch3',...
    false,...
    0,0,[],0,0);





































    pirelab.getConstComp(symDemodQPSKVector,lookUpTable11_out1_s89,real(blockInfo.LUTAdd04(1)));
    pirelab.getConstComp(symDemodQPSKVector,lookUpTable12_out1_s90,imag(blockInfo.LUTAdd04(1)));
    pirelab.getConstComp(symDemodQPSKVector,lookUpTable21_out1_s91,real(blockInfo.LUTAdd04(2)));
    pirelab.getConstComp(symDemodQPSKVector,lookUpTable22_out1_s92,imag(blockInfo.LUTAdd04(2)));
    pirelab.getConstComp(symDemodQPSKVector,lookUpTable31_out1_s93,real(blockInfo.LUTAdd04(3)));
    pirelab.getConstComp(symDemodQPSKVector,lookUpTable32_out1_s94,imag(blockInfo.LUTAdd04(3)));







    pirelab.getConstComp(symDemodQPSKVector,sin_out1_s96,blockInfo.LUTvalueImag);

    pirelab.getWireComp(symDemodQPSKVector,...
    t1_out1_s99,...
    DataTypeConversion9_out1_0_wire_out1_s29,...
    'Data Type Conversion9_out1_0_wire_out1');

    pirelab.getWireComp(symDemodQPSKVector,...
    t1_out2_s100,...
    DataTypeConversion9_out1_1_wire_out1_s30,...
    'Data Type Conversion9_out1_1_wire_out1');

    pirelab.getWireComp(symDemodQPSKVector,...
    Abs1_out1_s3,...
    PSKSymbolConverterBlock_out2_out1_s47,...
    'PSKSymbolConverterBlock_out2_out1');

    pirelab.getWireComp(symDemodQPSKVector,...
    Abs_out1_s2,...
    pskMapVec_out1_s95,...
    'pskMapVec_out1');

    pirelab.getWireComp(symDemodQPSKVector,...
    validIn_s1,...
    validOut1_out1_s101,...
    'validOut1_out1');


    pirelab.getAbsComp(symDemodQPSKVector,...
    DataTypeConversion11_out1_s16,...
    Abs_out1_s2,...
    'Floor','Wrap','Abs');


    pirelab.getAbsComp(symDemodQPSKVector,...
    DataTypeConversion12_out1_s17,...
    Abs1_out1_s3,...
    'Floor','Wrap','Abs1');


    pirelab.getAddComp(symDemodQPSKVector,...
    [DataTypeConversion3_out1_s22,DataTypeConversion4_out1_s23],...
    Add_out1_s4,...
    'Floor','Wrap','Add',pirTyp4,'++');


    pirelab.getAddComp(symDemodQPSKVector,...
    [DataTypeConversion5_out1_s24,DataTypeConversion6_out1_s25],...
    Add1_out1_s5,...
    'Floor','Wrap','Add1',pirTyp4,'++');


    pirelab.getAddComp(symDemodQPSKVector,...
    [PipelineRegister4_out1_s52,PipelineRegister5_out1_s53],...
    Add2_out1_s6,...
    'Floor','Wrap','Add2',pirTyp5,'+-');


    pirelab.getAddComp(symDemodQPSKVector,...
    [PipelineRegister7_out1_s55,PipelineRegister6_out1_s54],...
    Add3_out1_s7,...
    'Floor','Wrap','Add3',pirTyp5,'++');


    pirelab.getCompareToValueComp(symDemodQPSKVector,...
    DataTypeConversion11_out1_s16,...
    CompareToConstant_out1_s8,...
    '>',fi(0,nt1,fiMath1,'hex','000'),...
    'Compare To Constant',1);


    pirelab.getCompareToValueComp(symDemodQPSKVector,...
    DataTypeConversion12_out1_s17,...
    CompareToConstant1_out1_s9,...
    '>',fi(0,nt1,fiMath1,'hex','000'),...
    'Compare To Constant1',1);


    pirelab.getComplex2RealImag(symDemodQPSKVector,...
    dataIn_s0,...
    [ComplexToReal_Imag3_out1_s10,ComplexToReal_Imag3_out2_s11],...
    'Real and imag',...
    'Complex to Real-Imag3');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Switch10_out1_s73,...
    DataTypeConversion_out1_s13,...
    'Floor','Wrap','RWV','Data Type Conversion');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Subtract3_out1_s68,...
    DataTypeConversion1_out1_s14,...
    'Floor','Wrap','RWV','Data Type Conversion1');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Subtract2_out1_s67,...
    DataTypeConversion10_out1_s15,...
    'Floor','Wrap','RWV','Data Type Conversion10');


    pirelab.getDTCComp(symDemodQPSKVector,...
    PipelineRegister8_out1_s56,...
    DataTypeConversion11_out1_s16,...
    'Floor','Wrap','RWV','Data Type Conversion11');


    pirelab.getDTCComp(symDemodQPSKVector,...
    PipelineRegister9_out1_s57,...
    DataTypeConversion12_out1_s17,...
    'Floor','Wrap','RWV','Data Type Conversion12');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Subtract5_out1_s70,...
    DataTypeConversion13_out1_s18,...
    'Floor','Wrap','RWV','Data Type Conversion13');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Subtract6_out1_s71,...
    DataTypeConversion14_out1_s19,...
    'Floor','Wrap','RWV','Data Type Conversion14');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Subtract7_out1_s72,...
    DataTypeConversion15_out1_s20,...
    'Floor','Wrap','RWV','Data Type Conversion15');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Subtract1_out1_s66,...
    DataTypeConversion2_out1_s21,...
    'Floor','Wrap','RWV','Data Type Conversion2');


    pirelab.getDTCComp(symDemodQPSKVector,...
    PipelineRegister_out1_s48,...
    DataTypeConversion3_out1_s22,...
    'Floor','Wrap','RWV','Data Type Conversion3');


    pirelab.getDTCComp(symDemodQPSKVector,...
    PipelineRegister1_out1_s49,...
    DataTypeConversion4_out1_s23,...
    'Floor','Wrap','RWV','Data Type Conversion4');


    pirelab.getDTCComp(symDemodQPSKVector,...
    PipelineRegister2_out1_s50,...
    DataTypeConversion5_out1_s24,...
    'Floor','Wrap','RWV','Data Type Conversion5');


    pirelab.getDTCComp(symDemodQPSKVector,...
    PipelineRegister3_out1_s51,...
    DataTypeConversion6_out1_s25,...
    'Floor','Wrap','RWV','Data Type Conversion6');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Add_out1_s4,...
    DataTypeConversion7_out1_s26,...
    'Floor','Wrap','RWV','Data Type Conversion7');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Add1_out1_s5,...
    DataTypeConversion8_out1_s27,...
    'Floor','Wrap','RWV','Data Type Conversion8');


    pirelab.getDTCComp(symDemodQPSKVector,...
    Subtract4_out1_s69,...
    DataTypeConversion9_out1_s28,...
    'Floor','Wrap','RWV','Data Type Conversion9');


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister_out1_s31,HwModeRegister1_out1_s32],...
    Product_out1_s58,...
    'Floor','Wrap','Product','**','',-1,0);


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister2_out1_s39,HwModeRegister3_out1_s40],...
    Product1_out1_s59,...
    'Floor','Wrap','Product1','**','',-1,0);


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister4_out1_s41,HwModeRegister5_out1_s42],...
    Product2_out1_s60,...
    'Floor','Wrap','Product2','**','',-1,0);


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister6_out1_s43,HwModeRegister7_out1_s44],...
    Product3_out1_s61,...
    'Floor','Wrap','Product3','**','',-1,0);


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister8_out1_s45,HwModeRegister9_out1_s46],...
    Product4_out1_s62,...
    'Floor','Wrap','Product4','**','',-1,0);


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister10_out1_s33,HwModeRegister11_out1_s34],...
    Product5_out1_s63,...
    'Floor','Wrap','Product5','**','',-1,0);


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister12_out1_s35,HwModeRegister13_out1_s36],...
    Product6_out1_s64,...
    'Floor','Wrap','Product6','**','',-1,0);


    pirelab.getMulComp(symDemodQPSKVector,...
    [HwModeRegister14_out1_s37,HwModeRegister15_out1_s38],...
    Product7_out1_s65,...
    'Floor','Wrap','Product7','**','',-1,0);


    pirelab.getAddComp(symDemodQPSKVector,...
    [pskMapVec_out1_s95,lookUpTable21_out1_s91],...
    Subtract1_out1_s66,...
    'Floor','Wrap','Subtract1',pirTyp9,'+-');


    pirelab.getAddComp(symDemodQPSKVector,...
    [pskMapVec_out1_s95,lookUpTable31_out1_s93],...
    Subtract2_out1_s67,...
    'Floor','Wrap','Subtract2',pirTyp9,'+-');


    pirelab.getAddComp(symDemodQPSKVector,...
    [pskMapVec_out1_s95,lookUpTable11_out1_s89],...
    Subtract3_out1_s68,...
    'Floor','Wrap','Subtract3',pirTyp9,'+-');


    pirelab.getAddComp(symDemodQPSKVector,...
    [DataTypeConversion7_out1_s26,DataTypeConversion8_out1_s27],...
    Subtract4_out1_s69,...
    'Floor','Wrap','Subtract4',pirTyp4,'+-');


    pirelab.getAddComp(symDemodQPSKVector,...
    [PSKSymbolConverterBlock_out2_out1_s47,lookUpTable12_out1_s90],...
    Subtract5_out1_s70,...
    'Floor','Wrap','Subtract5',pirTyp9,'+-');


    pirelab.getAddComp(symDemodQPSKVector,...
    [PSKSymbolConverterBlock_out2_out1_s47,lookUpTable22_out1_s92],...
    Subtract6_out1_s71,...
    'Floor','Wrap','Subtract6',pirTyp9,'+-');


    pirelab.getAddComp(symDemodQPSKVector,...
    [PSKSymbolConverterBlock_out2_out1_s47,lookUpTable32_out1_s94],...
    Subtract7_out1_s72,...
    'Floor','Wrap','Subtract7',pirTyp9,'+-');


    pirelab.getSwitchComp(symDemodQPSKVector,...
    [concatenate_out1_s78,Constant5_out1_s12],...
    Switch10_out1_s73,...
    delayMatch2_out1_s87,'Switch10',...
    '>',0,'Floor','Wrap');


    pirelab.getSwitchComp(symDemodQPSKVector,...
    [UnaryMinus_out1_s76,DataTypeConversion9_out1_0_wire_out1_s29],...
    Switch2_out1_s74,...
    delayMatch1_out1_s86,'Switch2',...
    '>',0,'Floor','Wrap');


    pirelab.getSwitchComp(symDemodQPSKVector,...
    [UnaryMinus1_out1_s77,DataTypeConversion9_out1_1_wire_out1_s30],...
    Switch3_out1_s75,...
    delayMatch_out1_s85,'Switch3',...
    '>',0,'Floor','Wrap');


    pirelab.getUnaryMinusComp(symDemodQPSKVector,...
    DataTypeConversion9_out1_0_wire_out1_s29,...
    UnaryMinus_out1_s76,...
    'Wrap','Unary Minus');


    pirelab.getUnaryMinusComp(symDemodQPSKVector,...
    DataTypeConversion9_out1_1_wire_out1_s30,...
    UnaryMinus1_out1_s77,...
    'Wrap','Unary Minus1');


    pirelab.getMuxComp(symDemodQPSKVector,...
    [Switch3_out1_s75,Switch2_out1_s74],...
    concatenate_out1_s78,...
    'concatenate');


    pirelab.getMuxComp(symDemodQPSKVector,...
    [CompareToConstant_out1_s8,CompareToConstant1_out1_s9],...
    concatenate1_out1_s79,...
    'concatenate');


    pirelab.getMuxComp(symDemodQPSKVector,...
    [DataTypeConversion1_out1_s14,DataTypeConversion1_out1_s14],...
    concatenate2_out1_s80,...
    'concatenate');


    pirelab.getMuxComp(symDemodQPSKVector,...
    [DataTypeConversion2_out1_s21,DataTypeConversion10_out1_s15],...
    concatenate3_out1_s81,...
    'concatenate');


    pirelab.getMuxComp(symDemodQPSKVector,...
    [DataTypeConversion13_out1_s18,DataTypeConversion13_out1_s18],...
    concatenate4_out1_s82,...
    'concatenate');


    pirelab.getMuxComp(symDemodQPSKVector,...
    [DataTypeConversion14_out1_s19,DataTypeConversion15_out1_s20],...
    concatenate5_out1_s83,...
    'concatenate');


    pirelab.getDemuxComp(symDemodQPSKVector,...
    concatenate1_out1_s79,...
    [concatenate1_out1_0_s107,concatenate1_out1_1_s108],...
    '');

    pirelab.getWireComp(symDemodQPSKVector,...
    concatenate1_out1_0_s107,...
    t_out1_s97,...
    'concatenate1_out1_0_wire');

    pirelab.getWireComp(symDemodQPSKVector,...
    concatenate1_out1_1_s108,...
    t_out2_s98,...
    'concatenate1_out1_1_wire');


    pirelab.getDemuxComp(symDemodQPSKVector,...
    DataTypeConversion9_out1_s28,...
    [DataTypeConversion9_out1_0_s109,DataTypeConversion9_out1_1_s110],...
    '');

    pirelab.getWireComp(symDemodQPSKVector,...
    DataTypeConversion9_out1_0_s109,...
    t1_out1_s99,...
    'Data Type Conversion9_out1_0_wire');

    pirelab.getWireComp(symDemodQPSKVector,...
    DataTypeConversion9_out1_1_s110,...
    t1_out2_s100,...
    'Data Type Conversion9_out1_1_wire');


    pirelab.getWireComp(symDemodQPSKVector,DataTypeConversion_out1_s13,dataOut);
    pirelab.getWireComp(symDemodQPSKVector,delayMatch3_out1_s88,validOut);
end

function hS=addSignal(symDemodQPSKVector,sigName,pirTyp,simulinkRate)
    hS=symDemodQPSKVector.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end
