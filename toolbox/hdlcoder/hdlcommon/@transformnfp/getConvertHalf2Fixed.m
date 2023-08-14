function hTopN=getConvertHalf2Fixed(hN,slRate,WL,UWL,FL,rndMode,...
    satMode,flGtZero)









    p=pir(hN.getCtxName);
    topNwkName='nfp_convert_half_to_';
    if WL==UWL
        topNwkName=[topNwkName,'fix_'];
    else
        topNwkName=[topNwkName,'sfix_'];
    end
    topNwkName=[topNwkName,num2str(WL),'_En',num2str(FL)];

    hTopN=addNetworks(p,topNwkName);

    createNetworks(p,topNwkName,slRate,WL,UWL,FL,...
    rndMode,satMode,flGtZero);
end

function hTopN=addNetworks(p,topNwkName)
    hN=p.addNetwork;
    hN.Name=topNwkName;
    hN.FullPath=topNwkName;
    hTopN=hN;
    hN=p.addNetwork;
    hN.Name='Convert_Single2Fixed';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Single2Fixed');
    hN=p.addNetwork;
    hN.Name='AddSign';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Single2Fixed/AddSign');
    hN=p.addNetwork;
    hN.Name='ExponentBias';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Single2Fixed/ExponentBias');
    hN=p.addNetwork;
    hN.Name='Mantissa';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Single2Fixed/Mantissa');
    hN=p.addNetwork;
    hN.Name='S_TO_FIX';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Single2Fixed/S_TO_FIX');
    hN=p.addNetwork;
    hN.Name='over_underflow';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Single2Fixed/over_underflow');
end

function createNetworks(p,topNwkName,slRate,WL,UWL,FL,rndMode,...
    satMode,flGtZero)
    if FL<11
        guard=11-FL;
    else
        guard=0;
    end


    if(WL+guard)>127
        guard=127-WL;
    end
    hN_n6=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/over_underflow'));
    createNetwork_n6(p,hN_n6,slRate,WL,UWL,FL,guard);
    hN_n5=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/S_TO_FIX'));
    if~strcmp(rndMode,'Ceiling')&&~strcmp(rndMode,'Floor')
        createNetwork_n5(p,hN_n5,slRate,WL,UWL,FL,guard);
    else
        createNetwork_n5_ceil(p,hN_n5,slRate,WL,UWL,FL,guard);
    end
    hN_n4=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/Mantissa'));
    createNetwork_n4(p,hN_n4,slRate);
    hN_n3=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/ExponentBias'));
    createNetwork_n3(p,hN_n3,slRate);
    hN_n2=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/AddSign'));
    createNetwork_n2(p,hN_n2,slRate,WL,UWL,FL,guard,rndMode,satMode,flGtZero);
    hN_n1=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed'));
    createNetwork_n1(p,hN_n1,topNwkName,slRate,WL,UWL,FL,guard,flGtZero);
    hN_n0=p.findNetwork('fullname',topNwkName);
    createNetwork_n0(p,hN_n0,topNwkName,slRate,WL,UWL,FL,flGtZero);
end

function hN=createNetwork_n6(~,hN,slRate1,WL,UWL,FL,guard)
    pirTyp2=pir_boolean_t;
    pirTyp1=pir_ufixpt_t((WL+guard),-(FL+guard));

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,(WL+guard),(FL+guard));


    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate1);
    In1_s0.addDriver(hN,0);

    hN.addOutputPort('overflow');
    CompareToConstant1_out1_s2=addSignal(hN,'CompareTo Constant1_out1',pirTyp2,slRate1);
    CompareToConstant1_out1_s2.addReceiver(hN,0);

    hN.addOutputPort('underflow');
    CompareToConstant_out1_s1=addSignal(hN,'CompareTo Constant_out1',pirTyp2,slRate1);
    CompareToConstant_out1_s1.addReceiver(hN,1);



    pirelab.getCompareToValueComp(hN,...
    In1_s0,...
    CompareToConstant_out1_s1,...
    '<',fi(2^-(UWL-FL),nt1,fiMath1),...
    'CompareTo Constant',0);


    pirelab.getCompareToValueComp(hN,...
    In1_s0,...
    CompareToConstant1_out1_s2,...
    '>',fi(2^(UWL-FL),nt1,fiMath1),...
    'CompareTo Constant1',0);


end

function hN=createNetwork_n5(~,hN,slRate1,WL,~,FL,guard)

    pirTyp1=pir_sfixpt_t(6,0);
    pirTyp2=pir_ufixpt_t(11,-10);
    pirTyp3=pir_ufixpt_t((WL+guard),-(FL+guard));
    pirTyp4=pir_boolean_t;

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt3=numerictype(0,(WL+guard),(FL+guard));
    nt1=numerictype(1,6,0);

    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate1);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('In2');
    In2_s1=addSignal(hN,'In2',pirTyp2,slRate1);
    In2_s1.addDriver(hN,1);

    hN.addOutputPort('Out1');
    Switch1_out1_s12=addSignal(hN,'Switch1_out1',pirTyp3,slRate1);
    Switch1_out1_s12.addReceiver(hN,0);

    equality_s2=addSignal(hN,'equality',pirTyp4,slRate1);
    DataTypeConversion_out1_s3=addSignal(hN,'Data Type Conversion_out1',pirTyp3,slRate1);
    DataTypeConversion1_out1_s4=addSignal(hN,'Data Type Conversion1_out1',pirTyp3,slRate1);
    Delay4_out1_s7=addSignal(hN,'Delay4_out1',pirTyp3,slRate1);
    Delay5_out1_s8=addSignal(hN,'Delay5_out1',pirTyp4,slRate1);
    Delay6_out1_s9=addSignal(hN,'Delay6_out1',pirTyp3,slRate1);
    ShiftArithmetic1_out1_s10=addSignal(hN,sprintf('Shift\nArithmetic1_out1'),pirTyp3,slRate1);
    ShiftArithmetic2_out1_s11=addSignal(hN,sprintf('Shift\nArithmetic2_out1'),pirTyp3,slRate1);
    x_ve_s13=addSignal(hN,'-ve',pirTyp1,slRate1);
    shiftArithmetic1_selsig_s14=addSignal(hN,sprintf('shift\narithmetic1_selsig'),pirTyp1,slRate1);
    shiftArithmetic1_zerosig_s15=addSignal(hN,sprintf('shift\narithmetic1_zerosig'),pirTyp1,slRate1);
    shiftArithmetic2_selsig_s16=addSignal(hN,sprintf('shift\narithmetic2_selsig'),pirTyp1,slRate1);
    shiftArithmetic2_zerosig_s17=addSignal(hN,sprintf('shift\narithmetic2_zerosig'),pirTyp1,slRate1);


    pirelab.getIntDelayComp(hN,...
    ShiftArithmetic1_out1_s10,...
    Delay4_out1_s7,...
    transformnfp.Delay1,'Delay4',...
    fi(0,nt3,fiMath1,'hex','0000000000000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    equality_s2,...
    Delay5_out1_s8,...
    transformnfp.Delay1,'Delay5',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    ShiftArithmetic2_out1_s11,...
    Delay6_out1_s9,...
    transformnfp.Delay1,'Delay6',...
    fi(0,nt3,fiMath1,'hex','0000000000000000'),...
    0,0,[],0,0);


    pirelab.getCompareToValueComp(hN,...
    In1_s0,...
    equality_s2,...
    '>=',double(0),...
    'CompareTo Zero',0);


    pirelab.getDTCComp(hN,...
    In2_s1,...
    DataTypeConversion_out1_s3,...
    'Nearest','Wrap','RWV','Data Type Conversion');


    pirelab.getDTCComp(hN,...
    In2_s1,...
    DataTypeConversion1_out1_s4,...
    'Nearest','Wrap','RWV','Data Type Conversion1');


    pirelab.getConstComp(hN,...
    shiftArithmetic1_zerosig_s15,...
    fi(0,nt1,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [x_ve_s13,shiftArithmetic1_zerosig_s15],...
    shiftArithmetic1_selsig_s14,...
    sprintf('shift\narithmetic1_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [DataTypeConversion_out1_s3,shiftArithmetic1_selsig_s14],...
    ShiftArithmetic1_out1_s10,...
    'right','dynamic_shift');


    pirelab.getConstComp(hN,...
    shiftArithmetic2_zerosig_s17,...
    fi(0,nt1,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [In1_s0,shiftArithmetic2_zerosig_s17],...
    shiftArithmetic2_selsig_s16,...
    sprintf('shift\narithmetic2_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [DataTypeConversion1_out1_s4,shiftArithmetic2_selsig_s16],...
    ShiftArithmetic2_out1_s11,...
    'left','dynamic_shift');


    pirelab.getSwitchComp(hN,...
    [Delay6_out1_s9,Delay4_out1_s7],...
    Switch1_out1_s12,...
    Delay5_out1_s8,'Switch1',...
    '~=',0,'Floor','Wrap');


    pirelab.getUnaryMinusComp(hN,...
    In1_s0,...
    x_ve_s13,...
    'Wrap','Unary Minus');

end

function hN=createNetwork_n5_ceil(~,hN,slRate1,WL,~,FL,guard)
    pirTyp4=pir_boolean_t;
    pirTyp1=pir_sfixpt_t(6,0);
    pirTyp2=pir_ufixpt_t(11,-10);
    pirTyp3=pir_ufixpt_t((WL+guard),-(FL+guard));

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt3=numerictype(0,(WL+guard),(FL+guard));
    nt1=numerictype(1,6,0);

    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate1);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('In2');
    In2_s1=addSignal(hN,'In2',pirTyp2,slRate1);
    In2_s1.addDriver(hN,1);

    hN.addOutputPort('Out1');
    Switch1_out1_s17=addSignal(hN,'Switch1_out1',pirTyp3,slRate1);
    Switch1_out1_s17.addReceiver(hN,0);

    BitSet_out1_s2=addSignal(hN,'Bit Set_out1',pirTyp3,slRate1);
    CompareToZero_out1_s3=addSignal(hN,sprintf('Compare\nTo Zero_out1'),pirTyp4,slRate1);
    CompareToZero1_out1_s4=addSignal(hN,sprintf('Compare\nTo Zero1_out1'),pirTyp4,slRate1);
    equality_s5=addSignal(hN,'equality',pirTyp4,slRate1);
    DataTypeConversion_out1_s6=addSignal(hN,'Data Type Conversion_out1',pirTyp3,slRate1);
    DataTypeConversion1_out1_s7=addSignal(hN,'Data Type Conversion1_out1',pirTyp3,slRate1);
    Delay3_out1_s10=addSignal(hN,'Delay3_out1',pirTyp4,slRate1);
    Delay4_out1_s11=addSignal(hN,'Delay4_out1',pirTyp3,slRate1);
    Delay5_out1_s12=addSignal(hN,'Delay5_out1',pirTyp4,slRate1);
    Delay6_out1_s13=addSignal(hN,'Delay6_out1',pirTyp3,slRate1);
    LogicalOperator_out1_s14=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp4,slRate1);
    ShiftArithmetic1_out1_s15=addSignal(hN,sprintf('Shift\nArithmetic1_out1'),pirTyp3,slRate1);
    ShiftArithmetic2_out1_s16=addSignal(hN,sprintf('Shift\nArithmetic2_out1'),pirTyp3,slRate1);
    Switch2_out1_s18=addSignal(hN,'Switch2_out1',pirTyp3,slRate1);
    x_ve_s19=addSignal(hN,'-ve',pirTyp1,slRate1);
    shiftArithmetic1_selsig_s20=addSignal(hN,sprintf('shift\narithmetic1_selsig'),pirTyp1,slRate1);
    shiftArithmetic1_zerosig_s21=addSignal(hN,sprintf('shift\narithmetic1_zerosig'),pirTyp1,slRate1);
    shiftArithmetic2_selsig_s22=addSignal(hN,sprintf('shift\narithmetic2_selsig'),pirTyp1,slRate1);
    shiftArithmetic2_zerosig_s23=addSignal(hN,sprintf('shift\narithmetic2_zerosig'),pirTyp1,slRate1);


    pirelab.getIntDelayComp(hN,...
    LogicalOperator_out1_s14,...
    Delay3_out1_s10,...
    transformnfp.Delay1,'Delay3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    ShiftArithmetic1_out1_s15,...
    Delay4_out1_s11,...
    transformnfp.Delay1,'Delay4',...
    fi(0,nt3,fiMath1,'hex','00000000000000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    equality_s5,...
    Delay5_out1_s12,...
    transformnfp.Delay1,'Delay5',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    ShiftArithmetic2_out1_s16,...
    Delay6_out1_s13,...
    transformnfp.Delay1,'Delay6',...
    fi(0,nt3,fiMath1,'hex','00000000000000000'),...
    0,0,[],0,0);


    pirelab.getBitSetComp(hN,...
    Delay4_out1_s11,...
    BitSet_out1_s2,...
    1,1,...
    'Bit Set',1);


    pirelab.getCompareToValueComp(hN,...
    DataTypeConversion_out1_s6,...
    CompareToZero_out1_s3,...
    '~=',double(0),...
    sprintf('Compare\nTo Zero'),0);


    pirelab.getCompareToValueComp(hN,...
    ShiftArithmetic1_out1_s15,...
    CompareToZero1_out1_s4,...
    '==',double(0),...
    sprintf('Compare\nTo Zero1'),0);


    pirelab.getCompareToValueComp(hN,...
    In1_s0,...
    equality_s5,...
    '>=',double(0),...
    'CompareTo Zero',0);


    pirelab.getDTCComp(hN,...
    In2_s1,...
    DataTypeConversion_out1_s6,...
    'Nearest','Wrap','RWV','Data Type Conversion');


    pirelab.getDTCComp(hN,...
    In2_s1,...
    DataTypeConversion1_out1_s7,...
    'Nearest','Wrap','RWV','Data Type Conversion1');


    pirelab.getLogicComp(hN,...
    [CompareToZero1_out1_s4,CompareToZero_out1_s3],...
    LogicalOperator_out1_s14,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getConstComp(hN,...
    shiftArithmetic1_zerosig_s21,...
    fi(0,nt1,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [x_ve_s19,shiftArithmetic1_zerosig_s21],...
    shiftArithmetic1_selsig_s20,...
    sprintf('shift\narithmetic1_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [DataTypeConversion_out1_s6,shiftArithmetic1_selsig_s20],...
    ShiftArithmetic1_out1_s15,...
    'right','dynamic_shift');


    pirelab.getConstComp(hN,...
    shiftArithmetic2_zerosig_s23,...
    fi(0,nt1,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [In1_s0,shiftArithmetic2_zerosig_s23],...
    shiftArithmetic2_selsig_s22,...
    sprintf('shift\narithmetic2_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [DataTypeConversion1_out1_s7,shiftArithmetic2_selsig_s22],...
    ShiftArithmetic2_out1_s16,...
    'left','dynamic_shift');


    pirelab.getSwitchComp(hN,...
    [Delay6_out1_s13,Switch2_out1_s18],...
    Switch1_out1_s17,...
    Delay5_out1_s12,'Switch1',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [BitSet_out1_s2,Delay4_out1_s11],...
    Switch2_out1_s18,...
    Delay3_out1_s10,'Switch2',...
    '~=',0,'Floor','Wrap');


    pirelab.getUnaryMinusComp(hN,...
    In1_s0,...
    x_ve_s19,...
    'Wrap','Unary Minus');


end

function hN=createNetwork_n4(~,hN,slRate1)
    pirTyp5=pir_boolean_t;
    pirTyp2=pir_ufixpt_t(10,0);
    pirTyp4=pir_ufixpt_t(11,0);
    pirTyp3=pir_ufixpt_t(11,-10);
    pirTyp1=pir_ufixpt_t(5,0);




    hN.addInputPort('SE');
    SE_s0=addSignal(hN,'SE',pirTyp1,slRate1);
    SE_s0.addDriver(hN,0);

    hN.addInputPort('SM');
    SM_s1=addSignal(hN,'SM',pirTyp2,slRate1);
    SM_s1.addDriver(hN,1);

    hN.addOutputPort('0.M_1.M');
    DataTypeConversion1_out1_s4=addSignal(hN,'Data Type Conversion1_out1',pirTyp3,slRate1);
    DataTypeConversion1_out1_s4.addReceiver(hN,0);

    BitConcat_out1_s2=addSignal(hN,'Bit Concat_out1',pirTyp4,slRate1);
    CompareToZero_out1_s3=addSignal(hN,sprintf('Compare\nTo Zero_out1'),pirTyp5,slRate1);


    pirelab.getBitConcatComp(hN,...
    [CompareToZero_out1_s3,SM_s1],...
    BitConcat_out1_s2,...
    'Bit Concat');


    pirelab.getCompareToValueComp(hN,...
    SE_s0,...
    CompareToZero_out1_s3,...
    '~=',double(0),...
    sprintf('Compare\nTo Zero'),0);


    pirelab.getDTCComp(hN,...
    BitConcat_out1_s2,...
    DataTypeConversion1_out1_s4,...
    'Floor','Wrap','SI','Data Type Conversion1');


end

function hN=createNetwork_n3(~,hN,slRate1)
    pirTyp3=pir_boolean_t;
    pirTyp2=pir_sfixpt_t(6,0);
    pirTyp1=pir_ufixpt_t(5,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,5,0);


    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate1);
    In1_s0.addDriver(hN,0);

    hN.addOutputPort('Out1');
    x_ve_s1=addSignal(hN,'+ve',pirTyp2,slRate1);
    x_ve_s1.addReceiver(hN,0);

    CompareToZero1_out1_s2=addSignal(hN,sprintf('Compare\nTo Zero1_out1'),pirTyp3,slRate1);
    Constant2_out1_s3=addSignal(hN,'Constant2_out1',pirTyp1,slRate1);
    Constant3_out1_s4=addSignal(hN,'Constant3_out1',pirTyp1,slRate1);
    Switch2_out1_s5=addSignal(hN,'Switch2_out1',pirTyp1,slRate1);


    pirelab.getConstComp(hN,...
    Constant2_out1_s3,...
    fi(0,nt1,fiMath1,'hex','f'),...
    'Constant2','on',0,'','','');


    pirelab.getConstComp(hN,...
    Constant3_out1_s4,...
    fi(0,nt1,fiMath1,'hex','e'),...
    'Constant3','on',0,'','','');


    pirelab.getAddComp(hN,...
    [In1_s0,Switch2_out1_s5],...
    x_ve_s1,...
    'Floor','Wrap','Add',pirTyp2,'+-');


    pirelab.getCompareToValueComp(hN,...
    In1_s0,...
    CompareToZero1_out1_s2,...
    '~=',double(0),...
    sprintf('Compare\nTo Zero1'),0);


    pirelab.getSwitchComp(hN,...
    [Constant2_out1_s3,Constant3_out1_s4],...
    Switch2_out1_s5,...
    CompareToZero1_out1_s2,'Switch2',...
    '~=',0,'Floor','Wrap');


end


function hN=createNetwork_n2(~,hN,slRate1,WL,UWL,FL,guard,rndMode,...
    satMode,flGtZero)
    pirTyp2=pir_boolean_t;
    pirTyp1=pir_ufixpt_t((WL+guard),-(FL+guard));
    if WL==1

        pirTyp3=pir_ufixpt_t(1,-FL);
    else
        if flGtZero
            newWL=WL+1;
        else
            newWL=WL;
        end
        if WL==UWL
            pirTyp3=pir_ufixpt_t(newWL,-FL);
        else
            pirTyp3=pir_sfixpt_t(newWL,-FL);
        end
    end
    pirTyp4=pir_sfixpt_t((WL+guard+1),-(FL+guard));

    hN.addInputPort('Mul_result');
    Mul_result_s0=addSignal(hN,'Mul_result',pirTyp1,slRate1);
    Mul_result_s0.addDriver(hN,0);

    hN.addInputPort('Sign');
    Sign_s1=addSignal(hN,'Sign',pirTyp2,slRate1);
    Sign_s1.addDriver(hN,1);

    hN.addOutputPort('SFIX');
    DataTypeConversion2_out1_s3=addSignal(hN,'Data Type Conversion2_out1',pirTyp3,slRate1);
    DataTypeConversion2_out1_s3.addReceiver(hN,0);

    DataTypeConversion1_out1_s2=addSignal(hN,'Data Type Conversion1_out1',pirTyp4,slRate1);
    Switch1_out1_s4=addSignal(hN,'Switch1_out1',pirTyp4,slRate1);
    UnaryMinus_out1_s5=addSignal(hN,'Unary Minus_out1',pirTyp4,slRate1);


    pirelab.getDTCComp(hN,...
    Mul_result_s0,...
    DataTypeConversion1_out1_s2,...
    'Floor','Wrap','SI','Data Type Conversion1');


    pirelab.getDTCComp(hN,...
    Switch1_out1_s4,...
    DataTypeConversion2_out1_s3,...
    rndMode,satMode,'RWV','Data Type Conversion2');


    pirelab.getSwitchComp(hN,...
    [UnaryMinus_out1_s5,DataTypeConversion1_out1_s2],...
    Switch1_out1_s4,...
    Sign_s1,'Switch1',...
    '~=',0,'Floor','Wrap');


    pirelab.getUnaryMinusComp(hN,...
    DataTypeConversion1_out1_s2,...
    UnaryMinus_out1_s5,...
    'Wrap','Unary Minus');

end


function hN=createNetwork_n1(p,hN,topNwkName,slRate1,...
    WL,UWL,FL,guard,flGtZero)
    pirTyp1=pir_boolean_t;

    if WL==UWL
        if flGtZero
            pirTyp8=pir_ufixpt_t(WL+1,-FL);
        else
            pirTyp8=pir_ufixpt_t(WL,-FL);
        end
    else
        if flGtZero
            pirTyp8=pir_sfixpt_t(WL+1,-FL);
        else
            pirTyp8=pir_sfixpt_t(WL,-FL);
        end
    end
    pirTyp5=pir_sfixpt_t(6,0);
    pirTyp3=pir_ufixpt_t(10,0);
    pirTyp6=pir_ufixpt_t(11,-10);
    pirTyp7=pir_ufixpt_t((WL+guard),-(FL+guard));
    pirTyp2=pir_ufixpt_t(5,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt3=numerictype(0,10,0);
    if WL==1

        nt8=numerictype(0,1,FL);
    else
        if flGtZero
            nt8=numerictype(1,WL+1,FL);
        else
            nt8=numerictype(1,WL,FL);
        end
    end

    hN.addInputPort('XS');
    XS_s0=addSignal(hN,'XS',pirTyp1,slRate1);
    XS_s0.addDriver(hN,0);

    hN.addInputPort('XE');
    XE_s1=addSignal(hN,'XE',pirTyp2,slRate1);
    XE_s1.addDriver(hN,1);

    hN.addInputPort('XM');
    XM_s2=addSignal(hN,'XM',pirTyp3,slRate1);
    XM_s2.addDriver(hN,2);

    hN.addOutputPort('overflow');
    Delay6_out1_s12=addSignal(hN,'Delay6_out1',pirTyp1,slRate1);
    Delay6_out1_s12.addReceiver(hN,0);

    hN.addOutputPort('underflow');
    Delay7_out1_s13=addSignal(hN,'Delay7_out1',pirTyp1,slRate1);
    Delay7_out1_s13.addReceiver(hN,1);

    hN.addOutputPort('SFIX');
    Delay8_out1_s14=addSignal(hN,'Delay8_out1',pirTyp8,slRate1);
    Delay8_out1_s14.addReceiver(hN,2);

    AddSign_out1_s3=addSignal(hN,'AddSign_out1',pirTyp8,slRate1);
    Delay11_out1_s7=addSignal(hN,'Delay11_out1',pirTyp1,slRate1);
    Delay3_out1_s9=addSignal(hN,'Delay3_out1',pirTyp2,slRate1);
    Delay4_out1_s10=addSignal(hN,'Delay4_out1',pirTyp3,slRate1);
    Delay5_out1_s11=addSignal(hN,'Delay5_out1',pirTyp1,slRate1);
    x_ve_s16=addSignal(hN,'+ve',pirTyp5,slRate1);
    Mantissa_out1_s17=addSignal(hN,'Mantissa_out1',pirTyp6,slRate1);
    S_TO_FIX_out1_s18=addSignal(hN,'S_TO_FIX_out1',pirTyp7,slRate1);
    over_underflow_out1_s19=addSignal(hN,'over_underflow_out1',pirTyp1,slRate1);
    over_underflow_out2_s20=addSignal(hN,'over_underflow_out2',pirTyp1,slRate1);

    Constant_out1_s5=addSignal(hN,'Constant_out1',pirTyp8,slRate1);
    CompareToConstant_out1_s4=addSignal(hN,sprintf('Compare\nTo Constant_out1'),pirTyp1,slRate1);
    Delay12_out1_s10=addSignal(hN,'Delay12_out1',pirTyp1,slRate1);
    Switch_out1_s22=addSignal(hN,'Switch_out1',pirTyp8,slRate1);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/AddSign'));
    AddSign=hN.addComponent('ntwk_instance_comp',hRefN);
    AddSign.Name='AddSign';
    pirelab.connectNtwkInstComp(AddSign,...
    [S_TO_FIX_out1_s18,Delay11_out1_s7],...
    AddSign_out1_s3);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/ExponentBias'));
    ExponentBias=hN.addComponent('ntwk_instance_comp',hRefN);
    ExponentBias.Name='ExponentBias';
    pirelab.connectNtwkInstComp(ExponentBias,...
    Delay3_out1_s9,...
    x_ve_s16);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/Mantissa'));
    Mantissa=hN.addComponent('ntwk_instance_comp',hRefN);
    Mantissa.Name='Mantissa';
    pirelab.connectNtwkInstComp(Mantissa,...
    [Delay3_out1_s9,Delay4_out1_s10],...
    Mantissa_out1_s17);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/S_TO_FIX'));
    S_TO_FIX=hN.addComponent('ntwk_instance_comp',hRefN);
    S_TO_FIX.Name='S_TO_FIX';
    pirelab.connectNtwkInstComp(S_TO_FIX,...
    [x_ve_s16,Mantissa_out1_s17],...
    S_TO_FIX_out1_s18);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed/over_underflow'));
    over_underflow=hN.addComponent('ntwk_instance_comp',hRefN);
    over_underflow.Name='over_underflow';
    pirelab.connectNtwkInstComp(over_underflow,...
    S_TO_FIX_out1_s18,...
    [over_underflow_out1_s19,over_underflow_out2_s20]);

    pirelab.getConstComp(hN,...
    Constant_out1_s5,...
    0,...
    'Constant','on',1,'','','');


    pirelab.getIntDelayComp(hN,...
    Delay5_out1_s11,...
    Delay11_out1_s7,...
    transformnfp.Delay1,'Delay11',...
    false,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    XE_s1,...
    Delay3_out1_s9,...
    transformnfp.MinLatencyDelay1,'Delay3',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    XM_s2,...
    Delay4_out1_s10,...
    transformnfp.MinLatencyDelay1,'Delay4',...
    fi(0,nt3,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    XS_s0,...
    Delay5_out1_s11,...
    transformnfp.MinLatencyDelay1,'Delay5',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    over_underflow_out1_s19,...
    Delay6_out1_s12,...
    transformnfp.Delay1,'Delay6',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    over_underflow_out2_s20,...
    Delay7_out1_s13,...
    transformnfp.Delay1,'Delay7',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Switch_out1_s22,...
    Delay8_out1_s14,...
    transformnfp.Delay1,'Delay8',...
    fi(0,nt8,fiMath1,'hex','00000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    CompareToConstant_out1_s4,...
    Delay12_out1_s10,...
    transformnfp.Delay1,'Delay12',...
    false,...
    0,0,[],0,0);

    pirelab.getCompareToValueComp(hN,...
    Delay3_out1_s9,...
    CompareToConstant_out1_s4,...
    '==',fi(0,nt3,fiMath1,'hex','1f'),...
    sprintf('Compare\nTo Constant'),0);

    pirelab.getSwitchComp(hN,...
    [Constant_out1_s5,AddSign_out1_s3],...
    Switch_out1_s22,...
    Delay12_out1_s10,'Switch',...
    '~=',0,'Floor','Wrap');


end

function hN=createNetwork_n0(p,hN,topNwkName,slRate1,WL,UWL,FL,flGtZero)
    pirTyp1=pir_ufixpt_t(1,0);
    if WL==UWL
        if flGtZero
            pirTyp4=pir_ufixpt_t(WL+1,-FL);
        else
            pirTyp4=pir_ufixpt_t(WL,-FL);
        end
    else
        if flGtZero
            pirTyp4=pir_sfixpt_t(WL+1,-FL);
        else
            pirTyp4=pir_sfixpt_t(WL,-FL);
        end
    end
    pirTyp3=pir_ufixpt_t(10,0);
    pirTyp2=pir_ufixpt_t(5,0);




    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate1);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('In2');
    In2_s1=addSignal(hN,'In2',pirTyp2,slRate1);
    In2_s1.addDriver(hN,1);

    hN.addInputPort('In3');
    In3_s2=addSignal(hN,'In3',pirTyp3,slRate1);
    In3_s2.addDriver(hN,2);

    hN.addOutputPort('Out3');
    position_s5=addSignal(hN,'position',pirTyp4,slRate1);
    position_s5.addReceiver(hN,0);

    dummySignal1=addSignal(hN,'term1',pirTyp1,slRate1);
    dummySignal2=addSignal(hN,'term2',pirTyp1,slRate1);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Single2Fixed'));
    Convert_Single2Fixed=hN.addComponent('ntwk_instance_comp',hRefN);
    Convert_Single2Fixed.Name='Convert_Single2Fixed';
    pirelab.connectNtwkInstComp(Convert_Single2Fixed,...
    [In1_s0,In2_s1,In3_s2],...
    [dummySignal1,dummySignal2,position_s5]);


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end

function nwkName=getSubNwkName(topNwkName,ss)
    nwkName=[topNwkName,'/',ss];
end
