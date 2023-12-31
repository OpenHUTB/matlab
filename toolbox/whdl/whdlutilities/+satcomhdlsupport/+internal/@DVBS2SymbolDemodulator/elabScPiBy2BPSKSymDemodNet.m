function symDemodPiBy2BPSKSc=elabScPiBy2BPSKSymDemodNet(~,topNet,~,rate,inpWL,inpFL)





    pirTyp2=pir_boolean_t;
    pirTyp5=pir_sfixpt_t(16,-13);
    pirTyp1=pir_sfixpt_t(inpWL,inpFL);
    pirTyp3=pir_sfixpt_t(inpWL+3,inpFL);
    pirTyp7=pir_sfixpt_t(inpWL+16,inpFL-13);
    pirTyp4=pir_sfixpt_t(inpWL+16+1,inpFL-13);
    pirTyp6=pir_unsigned_t(8);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt3=numerictype(0,1,0);
    nt1=numerictype(1,16,13);
    nt4=numerictype(1,inpWL,-inpFL);
    nt2=numerictype(1,inpWL+3,-inpFL);
    nt5=numerictype(1,inpWL+16,-(inpFL-13));


    inportNamePiBy2BPSK={'dataIn','validIn'};
    controlType=pir_ufixpt_t(1,0);
    inType=pir_complex_t(pir_sfixpt_t(inpWL,inpFL));
    inTypePiBy2BPSK=[inType,controlType];
    inDataRatePiBy2BPSK=[rate,rate];

    outportNamePiBy2BPSK={'dataOut','validOut'};
    outTypePiBy2BPSK=[pirTyp3,controlType];

    symDemodPiBy2BPSKSc=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','symDemodPiBy2BPSKSc',...
    'InportNames',inportNamePiBy2BPSK,...
    'InportTypes',inTypePiBy2BPSK,...
    'InportRates',inDataRatePiBy2BPSK,...
    'OutportNames',outportNamePiBy2BPSK,...
    'OutportTypes',outTypePiBy2BPSK...
    );



    dataIn_s0=symDemodPiBy2BPSKSc.PirInputSignals(1);
    validIn_s1=symDemodPiBy2BPSKSc.PirInputSignals(2);

    dataOut=symDemodPiBy2BPSKSc.PirOutputSignals(1);
    validOut=symDemodPiBy2BPSKSc.PirOutputSignals(2);

    slRate1=rate;

    Switch1_out1_s21=addSignal(symDemodPiBy2BPSKSc,'Switch1_out1',pirTyp3,slRate1);

    delayMatch2_out1_s24=addSignal(symDemodPiBy2BPSKSc,'delayMatch2_out1',pirTyp2,slRate1);

    Add_out1_s2=addSignal(symDemodPiBy2BPSKSc,'Add_out1',pirTyp4,slRate1);
    Add1_out1_s3=addSignal(symDemodPiBy2BPSKSc,'Add1_out1',pirTyp4,slRate1);
    ComplexToReal_Imag_out1_s4=addSignal(symDemodPiBy2BPSKSc,'Complex to Real-Imag_out1',pirTyp1,slRate1);
    ComplexToReal_Imag_out2_s5=addSignal(symDemodPiBy2BPSKSc,'Complex to Real-Imag_out2',pirTyp1,slRate1);
    Constant_out1_s6=addSignal(symDemodPiBy2BPSKSc,'Constant_out1',pirTyp5,slRate1);
    Constant1_out1_s7=addSignal(symDemodPiBy2BPSKSc,'Constant1_out1',pirTyp5,slRate1);
    Constant10_out1_s8=addSignal(symDemodPiBy2BPSKSc,'Constant10_out1',pirTyp3,slRate1);
    Constant2_out1_s9=addSignal(symDemodPiBy2BPSKSc,'Constant2_out1',pirTyp2,slRate1);
    DataTypeConversion_out1_s10=addSignal(symDemodPiBy2BPSKSc,'Data Type Conversion_out1',pirTyp3,slRate1);
    EvenSymCounter_out1_s11=addSignal(symDemodPiBy2BPSKSc,'Even sym counter_out1',pirTyp6,slRate1);
    HwModeRegister_out1_s12=addSignal(symDemodPiBy2BPSKSc,'HwModeRegister_out1',pirTyp5,slRate1);
    HwModeRegister1_out1_s13=addSignal(symDemodPiBy2BPSKSc,'HwModeRegister1_out1',pirTyp1,slRate1);
    HwModeRegister2_out1_s14=addSignal(symDemodPiBy2BPSKSc,'HwModeRegister2_out1',pirTyp1,slRate1);
    HwModeRegister3_out1_s15=addSignal(symDemodPiBy2BPSKSc,'HwModeRegister3_out1',pirTyp5,slRate1);
    PipelineRegister_out1_s16=addSignal(symDemodPiBy2BPSKSc,'PipelineRegister_out1',pirTyp7,slRate1);
    PipelineRegister1_out1_s17=addSignal(symDemodPiBy2BPSKSc,'PipelineRegister1_out1',pirTyp7,slRate1);
    Product_out1_s18=addSignal(symDemodPiBy2BPSKSc,'Product_out1',pirTyp7,slRate1);
    Product1_out1_s19=addSignal(symDemodPiBy2BPSKSc,'Product1_out1',pirTyp7,slRate1);
    Switch_out1_s20=addSignal(symDemodPiBy2BPSKSc,'Switch_out1',pirTyp4,slRate1);
    delayMatch_out1_s22=addSignal(symDemodPiBy2BPSKSc,'delayMatch_out1',pirTyp6,slRate1);
    delayMatch1_out1_s23=addSignal(symDemodPiBy2BPSKSc,'delayMatch1_out1',pirTyp2,slRate1);


    pirelab.getConstComp(symDemodPiBy2BPSKSc,...
    Constant_out1_s6,...
    fi(0,nt1,fiMath1,'hex','5a82'),...
    'Constant','on',0,'','','');


    pirelab.getConstComp(symDemodPiBy2BPSKSc,...
    Constant1_out1_s7,...
    fi(0,nt1,fiMath1,'hex','5a82'),...
    'Constant1','on',0,'','','');


    pirelab.getConstComp(symDemodPiBy2BPSKSc,...
    Constant10_out1_s8,...
    fi(0,nt2,fiMath1,'hex','00000'),...
    'Constant10','on',1,'','','');


    pirelab.getConstComp(symDemodPiBy2BPSKSc,...
    Constant2_out1_s9,...
    fi(0,nt3,fiMath1,'hex','0'),...
    'Constant2','on',1,'','','');

    pirelab.getAnnotationComp(symDemodPiBy2BPSKSc,...
    'Data Type Duplicate');


    pirelab.getCounterComp(symDemodPiBy2BPSKSc,...
    [Constant2_out1_s9,validIn_s1],...
    EvenSymCounter_out1_s11,...
    'Count limited',1,-1,0,1,0,1,0,'Even sym counter',1);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    Constant_out1_s6,...
    HwModeRegister_out1_s12,...
    1,'HwModeRegister',...
    fi(0,nt1,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    ComplexToReal_Imag_out1_s4,...
    HwModeRegister1_out1_s13,...
    1,'HwModeRegister1',...
    fi(0,nt4,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    ComplexToReal_Imag_out2_s5,...
    HwModeRegister2_out1_s14,...
    1,'HwModeRegister2',...
    fi(0,nt4,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    Constant1_out1_s7,...
    HwModeRegister3_out1_s15,...
    1,'HwModeRegister3',...
    fi(0,nt1,fiMath1,'hex','0000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    Product_out1_s18,...
    PipelineRegister_out1_s16,...
    1,'PipelineRegister',...
    fi(0,nt5,fiMath1,'hex','00000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    Product1_out1_s19,...
    PipelineRegister1_out1_s17,...
    1,'PipelineRegister1',...
    fi(0,nt5,fiMath1,'hex','00000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    EvenSymCounter_out1_s11,...
    delayMatch_out1_s22,...
    2,'delayMatch',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    validIn_s1,...
    delayMatch1_out1_s23,...
    2,'delayMatch1',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(symDemodPiBy2BPSKSc,...
    validIn_s1,...
    delayMatch2_out1_s24,...
    2,'delayMatch2',...
    false,...
    0,0,[],0,0);


    pirelab.getAddComp(symDemodPiBy2BPSKSc,...
    [PipelineRegister_out1_s16,PipelineRegister1_out1_s17],...
    Add_out1_s2,...
    'Floor','Wrap','Add',pirTyp4,'++');


    pirelab.getAddComp(symDemodPiBy2BPSKSc,...
    [PipelineRegister1_out1_s17,PipelineRegister_out1_s16],...
    Add1_out1_s3,...
    'Floor','Wrap','Add1',pirTyp4,'+-');


    pirelab.getComplex2RealImag(symDemodPiBy2BPSKSc,...
    dataIn_s0,...
    [ComplexToReal_Imag_out1_s4,ComplexToReal_Imag_out2_s5],...
    'Real and imag',...
    'Complex to Real-Imag');


    pirelab.getDTCComp(symDemodPiBy2BPSKSc,...
    Switch_out1_s20,...
    DataTypeConversion_out1_s10,...
    'Floor','Wrap','RWV','Data Type Conversion');


    pirelab.getMulComp(symDemodPiBy2BPSKSc,...
    [HwModeRegister_out1_s12,HwModeRegister1_out1_s13],...
    Product_out1_s18,...
    'Floor','Wrap','Product','**','',-1,0);


    pirelab.getMulComp(symDemodPiBy2BPSKSc,...
    [HwModeRegister2_out1_s14,HwModeRegister3_out1_s15],...
    Product1_out1_s19,...
    'Floor','Wrap','Product1','**','',-1,0);


    pirelab.getSwitchComp(symDemodPiBy2BPSKSc,...
    [Add_out1_s2,Add1_out1_s3],...
    Switch_out1_s20,...
    delayMatch_out1_s22,'Switch',...
    '>',0,'Floor','Wrap');


    pirelab.getSwitchComp(symDemodPiBy2BPSKSc,...
    [DataTypeConversion_out1_s10,Constant10_out1_s8],...
    Switch1_out1_s21,...
    delayMatch1_out1_s23,'Switch1',...
    '>',0,'Floor','Wrap');



    pirelab.getWireComp(symDemodPiBy2BPSKSc,Switch1_out1_s21,dataOut);
    pirelab.getWireComp(symDemodPiBy2BPSKSc,delayMatch2_out1_s24,validOut);
end

function hS=addSignal(symDemodPiBy2BPSKSc,sigName,pirTyp,simulinkRate)
    hS=symDemodPiBy2BPSKSc.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end