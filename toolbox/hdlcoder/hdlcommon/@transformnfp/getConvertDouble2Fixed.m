function hTopN=getConvertDouble2Fixed(hN,latency,slRate,WL,UWL,FL,rndMode,satMode,flGtZero)




    p=pir(hN.getCtxName);
    topNwkName='nfp_convert_double_to_fixed_';
    topNwkName=[topNwkName,num2str(WL),'_En',num2str(FL)];
    hTopN=addNetworks(p,topNwkName);

    pipestage=zeros(1,6);
    switch latency
    case 0
        pipestage=zeros(1,6);
    case 1
        pipestage(3)=1;
    case 2
        pipestage=[0,1,0,0,1,0];
    case 3
        pipestage=[0,1,0,1,0,1];
    case 4
        pipestage=[1,0,1,1,0,1];
    case 5
        pipestage=[1,0,1,1,1,1];
    case 6
        pipestage=[1,1,1,1,1,1];
    otherwise
        assert(false,'Illegal latency number in nfp_dtc_comp.');
    end

    createNetworks(p,topNwkName,pipestage,slRate,WL,UWL,FL,rndMode,satMode,flGtZero);
end

function hTopN=addNetworks(p,topNwkName)
    hN=p.addNetwork;
    hN.Name=topNwkName;
    hN.FullPath=topNwkName;
    hTopN=hN;
    hN=p.addNetwork;
    hN.Name='Convert_Double2Fixed';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Double2Fixed');
    hN=p.addNetwork;
    hN.Name='AddSign';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Double2Fixed/AddSign');
    hN=p.addNetwork;
    hN.Name='ExponentBias_and_Mantissa';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Double2Fixed/ExponentBias_and_Mantissa');
    hN=p.addNetwork;
    hN.Name='D_TO_FIX';
    hN.FullPath=getSubNwkName(topNwkName,'Convert_Double2Fixed/D_TO_FIX');
end

function createNetworks(p,topNwkName,pipestage,slRate,WL,UWL,FL,rndMode,satMode,flGtZero)

    if FL<53
        guard=53-FL;
    else
        guard=0;
    end

    if(WL+guard)>127
        guard=127-WL;
    end
    hN_n4=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed/D_TO_FIX'));
    if~strcmp(rndMode,'Ceiling')&&~strcmp(rndMode,'Floor')
        createNetwork_n4(p,hN_n4,pipestage,slRate,WL,FL,guard);
    else
        createNetwork_n4_ceil(p,hN_n4,pipestage,slRate,WL,FL,guard);
    end
    hN_n3=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed/ExponentBias_and_Mantissa'));
    createNetwork_n3(p,hN_n3,slRate);
    hN_n2=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed/AddSign'));
    createNetwork_n2(p,hN_n2,pipestage,slRate,WL,UWL,FL,guard,rndMode,satMode,flGtZero);
    hN_n1=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed'));
    createNetwork_n1(p,hN_n1,topNwkName,pipestage,slRate,WL,UWL,FL,guard,flGtZero);
    hN_n0=p.findNetwork('fullname',topNwkName);
    createNetwork_n0(p,hN_n0,topNwkName,slRate,WL,UWL,FL,flGtZero);

end

function hN=createNetwork_n4(~,hN,pipestage,slRate,WL,FL,guard)

    pirTyp1=pir_sfixpt_t(12,0);
    pirTyp2=pir_ufixpt_t(53,-52);
    pirTyp3=pir_ufixpt_t((WL+guard),-(FL+guard));

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt2=numerictype(0,(WL+guard),(FL+guard));
    nt1=numerictype(1,12,0);

    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('In2');
    In2_s1=addSignal(hN,'In2',pirTyp2,slRate);
    In2_s1.addDriver(hN,1);

    hN.addOutputPort('Out1');
    Switch1_out1_s13=addSignal(hN,'Switch1_out1',pirTyp3,slRate);
    Switch1_out1_s13.addReceiver(hN,0);

    DataTypeConversion1_out1_s2=addSignal(hN,'Data Type Conversion1_out1',pirTyp3,slRate);
    Delay10_out1_s3=addSignal(hN,'Delay10_out1',pirTyp1,slRate);
    Delay3_out1_s4=addSignal(hN,'Delay3_out1',pirTyp3,slRate);
    Delay4_out1_s5=addSignal(hN,'Delay4_out1',pirTyp3,slRate);
    Delay5_out1_s6=addSignal(hN,'Delay5_out1',pirTyp1,slRate);
    Delay6_out1_s7=addSignal(hN,'Delay6_out1',pirTyp3,slRate);
    Delay7_out1_s8=addSignal(hN,'Delay7_out1',pirTyp1,slRate);
    Delay8_out1_s9=addSignal(hN,'Delay8_out1',pirTyp1,slRate);
    Delay9_out1_s10=addSignal(hN,'Delay9_out1',pirTyp3,slRate);
    ShiftArithmetic1_out1_s11=addSignal(hN,sprintf('Shift\nArithmetic1_out1'),pirTyp3,slRate);
    ShiftArithmetic2_out1_s12=addSignal(hN,sprintf('Shift\nArithmetic2_out1'),pirTyp3,slRate);
    x_ve_s14=addSignal(hN,'-ve',pirTyp1,slRate);
    shiftArithmetic1_selsig_s15=addSignal(hN,sprintf('shift\narithmetic1_selsig'),pirTyp1,slRate);
    shiftArithmetic1_zerosig_s16=addSignal(hN,sprintf('shift\narithmetic1_zerosig'),pirTyp1,slRate);
    shiftArithmetic2_selsig_s17=addSignal(hN,sprintf('shift\narithmetic2_selsig'),pirTyp1,slRate);
    shiftArithmetic2_zerosig_s18=addSignal(hN,sprintf('shift\narithmetic2_zerosig'),pirTyp1,slRate);

    pirelab.getIntDelayComp(hN,...
    x_ve_s14,...
    Delay10_out1_s3,...
    pipestage(2),'Delay10',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    DataTypeConversion1_out1_s2,...
    Delay3_out1_s4,...
    pipestage(2),'Delay3',...
    fi(0,nt2,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    ShiftArithmetic1_out1_s11,...
    Delay4_out1_s5,...
    pipestage(3),'Delay4',...
    fi(0,nt2,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    Delay8_out1_s9,...
    Delay5_out1_s6,...
    pipestage(3),'Delay5',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    ShiftArithmetic2_out1_s12,...
    Delay6_out1_s7,...
    pipestage(3),'Delay6',...
    fi(0,nt2,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    In1_s0,...
    Delay7_out1_s8,...
    pipestage(2),'Delay7',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    In1_s0,...
    Delay8_out1_s9,...
    pipestage(2),'Delay8',...
    fi(0,nt1,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    DataTypeConversion1_out1_s2,...
    Delay9_out1_s10,...
    pipestage(2),'Delay9',...
    fi(0,nt2,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getDTCComp(hN,...
    In2_s1,...
    DataTypeConversion1_out1_s2,...
    'Nearest','Wrap','RWV','Data Type Conversion1');

    pirelab.getConstComp(hN,...
    shiftArithmetic1_zerosig_s16,...
    fi(0,nt1,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [Delay10_out1_s3,shiftArithmetic1_zerosig_s16],...
    shiftArithmetic1_selsig_s15,...
    sprintf('shift\narithmetic1_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [Delay9_out1_s10,shiftArithmetic1_selsig_s15],...
    ShiftArithmetic1_out1_s11,...
    'right',sprintf('shift\narithmetic1'));

    pirelab.getConstComp(hN,...
    shiftArithmetic2_zerosig_s18,...
    fi(0,nt1,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [Delay7_out1_s8,shiftArithmetic2_zerosig_s18],...
    shiftArithmetic2_selsig_s17,...
    sprintf('shift\narithmetic2_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [Delay3_out1_s4,shiftArithmetic2_selsig_s17],...
    ShiftArithmetic2_out1_s12,...
    'left',sprintf('shift\narithmetic2'));

    pirelab.getSwitchComp(hN,...
    [Delay6_out1_s7,Delay4_out1_s5],...
    Switch1_out1_s13,...
    Delay5_out1_s6,'Switch1',...
    '>=',0,'Floor','Wrap');

    pirelab.getUnaryMinusComp(hN,...
    In1_s0,...
    x_ve_s14,...
    'Wrap','Unary Minus');

end

function hN=createNetwork_n4_ceil(~,hN,pipestage,slRate,WL,FL,guard)

    pirTyp4=pir_ufixpt_t(1,0);
    pirTyp1=pir_sfixpt_t(12,0);
    pirTyp2=pir_ufixpt_t(53,-52);
    pirTyp3=pir_ufixpt_t((WL+guard),-(FL+guard));

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,(WL+guard),(FL+guard));
    nt2=numerictype(1,12,0);

    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('In2');
    In2_s1=addSignal(hN,'In2',pirTyp2,slRate);
    In2_s1.addDriver(hN,1);

    hN.addOutputPort('Out1');
    Switch1_out1_s18=addSignal(hN,'Switch1_out1',pirTyp3,slRate);
    Switch1_out1_s18.addReceiver(hN,0);

    BitSet_out1_s2=addSignal(hN,'Bit Set_out1',pirTyp3,slRate);
    CompareToZero_out1_s3=addSignal(hN,sprintf('Compare\nTo Zero_out1'),pirTyp4,slRate);
    CompareToZero1_out1_s4=addSignal(hN,sprintf('Compare\nTo Zero1_out1'),pirTyp4,slRate);
    DataTypeConversion1_out1_s5=addSignal(hN,'Data Type Conversion1_out1',pirTyp3,slRate);
    Delay1_out1_s6=addSignal(hN,'Delay1_out1',pirTyp3,slRate);
    Delay10_out1_s7=addSignal(hN,'Delay10_out1',pirTyp1,slRate);
    Delay2_out1_s8=addSignal(hN,'Delay2_out1',pirTyp3,slRate);
    Delay4_out1_s9=addSignal(hN,'Delay4_out1',pirTyp3,slRate);
    Delay5_out1_s10=addSignal(hN,'Delay5_out1',pirTyp1,slRate);
    Delay6_out1_s11=addSignal(hN,'Delay6_out1',pirTyp3,slRate);
    Delay7_out1_s12=addSignal(hN,'Delay7_out1',pirTyp1,slRate);
    equality_s13=addSignal(hN,'equality',pirTyp1,slRate);
    Delay9_out1_s14=addSignal(hN,'Delay9_out1',pirTyp3,slRate);
    LogicalOperator_out1_s15=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp4,slRate);
    ShiftArithmetic1_out1_s16=addSignal(hN,sprintf('Shift\nArithmetic1_out1'),pirTyp3,slRate);
    ShiftArithmetic2_out1_s17=addSignal(hN,sprintf('Shift\nArithmetic2_out1'),pirTyp3,slRate);
    Switch2_out1_s19=addSignal(hN,'Switch2_out1',pirTyp3,slRate);
    x_ve_s20=addSignal(hN,'-ve',pirTyp1,slRate);
    shiftArithmetic1_selsig_s21=addSignal(hN,sprintf('shift\narithmetic1_selsig'),pirTyp1,slRate);
    shiftArithmetic1_zerosig_s22=addSignal(hN,sprintf('shift\narithmetic1_zerosig'),pirTyp1,slRate);
    shiftArithmetic2_selsig_s23=addSignal(hN,sprintf('shift\narithmetic2_selsig'),pirTyp1,slRate);
    shiftArithmetic2_zerosig_s24=addSignal(hN,sprintf('shift\narithmetic2_zerosig'),pirTyp1,slRate);

    pirelab.getIntDelayComp(hN,...
    DataTypeConversion1_out1_s5,...
    Delay1_out1_s6,...
    pipestage(2),'Delay1',...
    fi(0,nt1,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    x_ve_s20,...
    Delay10_out1_s7,...
    pipestage(2),'Delay10',...
    fi(0,nt2,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    DataTypeConversion1_out1_s5,...
    Delay2_out1_s8,...
    pipestage(2),'Delay2',...
    fi(0,nt1,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    Switch2_out1_s19,...
    Delay4_out1_s9,...
    pipestage(3),'Delay4',...
    fi(0,nt1,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    equality_s13,...
    Delay5_out1_s10,...
    pipestage(3),'Delay5',...
    fi(0,nt2,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    ShiftArithmetic2_out1_s17,...
    Delay6_out1_s11,...
    pipestage(3),'Delay6',...
    fi(0,nt1,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    In1_s0,...
    Delay7_out1_s12,...
    pipestage(2),'Delay7',...
    fi(0,nt2,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    In1_s0,...
    equality_s13,...
    pipestage(2),'Delay8',...
    fi(0,nt2,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    DataTypeConversion1_out1_s5,...
    Delay9_out1_s14,...
    pipestage(2),'Delay9',...
    fi(0,nt1,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getBitSetComp(hN,...
    ShiftArithmetic1_out1_s16,...
    BitSet_out1_s2,...
    1,1,...
    'Bit Set',1);

    pirelab.getCompareToValueComp(hN,...
    Delay2_out1_s8,...
    CompareToZero_out1_s3,...
    '~=',double(0),...
    sprintf('Compare\nTo Zero'),0);

    pirelab.getCompareToValueComp(hN,...
    ShiftArithmetic1_out1_s16,...
    CompareToZero1_out1_s4,...
    '==',double(0),...
    sprintf('Compare\nTo Zero1'),0);

    pirelab.getDTCComp(hN,...
    In2_s1,...
    DataTypeConversion1_out1_s5,...
    'Nearest','Wrap','RWV','Data Type Conversion1');

    pirelab.getLogicComp(hN,...
    [CompareToZero1_out1_s4,CompareToZero_out1_s3],...
    LogicalOperator_out1_s15,...
    'and',sprintf('Logical\nOperator'));

    pirelab.getConstComp(hN,...
    shiftArithmetic1_zerosig_s22,...
    fi(0,nt2,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [Delay10_out1_s7,shiftArithmetic1_zerosig_s22],...
    shiftArithmetic1_selsig_s21,...
    sprintf('shift\narithmetic1_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [Delay9_out1_s14,shiftArithmetic1_selsig_s21],...
    ShiftArithmetic1_out1_s16,...
    'right',sprintf('shift\narithmetic1'));

    pirelab.getConstComp(hN,...
    shiftArithmetic2_zerosig_s24,...
    fi(0,nt2,fiMath1,'hex','000'),...
    'const','on',0,'','','');

    pirelab.getMinMaxComp(hN,...
    [Delay7_out1_s12,shiftArithmetic2_zerosig_s24],...
    shiftArithmetic2_selsig_s23,...
    sprintf('shift\narithmetic2_nonneg'),'max',0,'Value',1);

    pirelab.getDynamicBitShiftComp(hN,...
    [Delay1_out1_s6,shiftArithmetic2_selsig_s23],...
    ShiftArithmetic2_out1_s17,...
    'left',sprintf('shift\narithmetic2'));

    pirelab.getSwitchComp(hN,...
    [Delay6_out1_s11,Delay4_out1_s9],...
    Switch1_out1_s18,...
    Delay5_out1_s10,'Switch1',...
    '>=',0,'Floor','Wrap');

    pirelab.getSwitchComp(hN,...
    [BitSet_out1_s2,ShiftArithmetic1_out1_s16],...
    Switch2_out1_s19,...
    LogicalOperator_out1_s15,'Switch2',...
    '~=',0,'Floor','Wrap');

    pirelab.getUnaryMinusComp(hN,...
    In1_s0,...
    x_ve_s20,...
    'Wrap','Unary Minus');

end

function hN=createNetwork_n3(~,hN,slRate)

    pirTyp6=pir_ufixpt_t(1,0);
    pirTyp3=pir_sfixpt_t(12,0);
    pirTyp1=pir_ufixpt_t(11,0);
    pirTyp2=pir_ufixpt_t(52,0);
    pirTyp5=pir_ufixpt_t(53,0);
    pirTyp4=pir_ufixpt_t(53,-52);
    pirTyp7=pir_unsigned_t(16);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,16,0);

    hN.addInputPort('E');
    In1_s0=addSignal(hN,'E',pirTyp1,slRate);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('M');
    In2_s1=addSignal(hN,'M',pirTyp2,slRate);
    In2_s1.addDriver(hN,1);

    hN.addOutputPort('SignedExp');
    x_ve_s2=addSignal(hN,'+ve',pirTyp3,slRate);
    x_ve_s2.addReceiver(hN,0);

    hN.addOutputPort('0.M_1.M');
    DataTypeConversion1_out1_s7=addSignal(hN,'Data Type Conversion1_out1',pirTyp4,slRate);
    DataTypeConversion1_out1_s7.addReceiver(hN,1);

    BitConcat_out1_s3=addSignal(hN,'Bit Concat_out1',pirTyp5,slRate);
    CompareToZero_out1_s4=addSignal(hN,sprintf('Compare\nTo Zero_out1'),pirTyp6,slRate);
    Constant2_out1_s5=addSignal(hN,'Constant2_out1',pirTyp7,slRate);
    Constant3_out1_s6=addSignal(hN,'Constant3_out1',pirTyp7,slRate);
    Switch2_out1_s8=addSignal(hN,'Switch2_out1',pirTyp7,slRate);

    pirelab.getConstComp(hN,...
    Constant2_out1_s5,...
    fi(0,nt1,fiMath1,'hex','03ff'),...
    'Constant2','on',0,'','','');

    pirelab.getConstComp(hN,...
    Constant3_out1_s6,...
    fi(0,nt1,fiMath1,'hex','03fe'),...
    'Constant3','on',0,'','','');

    pirelab.getAddComp(hN,...
    [In1_s0,Switch2_out1_s8],...
    x_ve_s2,...
    'Floor','Wrap','Add',pirTyp3,'+-');

    pirelab.getBitConcatComp(hN,...
    [CompareToZero_out1_s4,In2_s1],...
    BitConcat_out1_s3,...
    'Bit Concat');

    pirelab.getCompareToValueComp(hN,...
    In1_s0,...
    CompareToZero_out1_s4,...
    '~=',double(0),...
    sprintf('Compare\nTo Zero'),0);

    pirelab.getDTCComp(hN,...
    BitConcat_out1_s3,...
    DataTypeConversion1_out1_s7,...
    'Floor','Wrap','SI','Data Type Conversion1');

    pirelab.getSwitchComp(hN,...
    [Constant2_out1_s5,Constant3_out1_s6],...
    Switch2_out1_s8,...
    In1_s0,'Switch2',...
    '~=',0,'Floor','Wrap');

end

function hN=createNetwork_n2(~,hN,pipestage,slRate,WL,UWL,FL,guard,rndMode,satMode,flGtZero)

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
    pirTyp2=pir_ufixpt_t(1,0);
    pirTyp1=pir_ufixpt_t((WL+guard),-(FL+guard));

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt3=numerictype(0,1,0);
    nt2=numerictype(0,(WL+guard),(FL+guard));
    nt1=numerictype(1,(WL+guard+1),(FL+guard));
    if WL==UWL
        nt4=numerictype(0,WL,FL);
    else
        nt4=numerictype(1,WL,FL);
    end

    hN.addInputPort('Mul_result');
    Mul_result_s0=addSignal(hN,'Mul_result',pirTyp1,slRate);
    Mul_result_s0.addDriver(hN,0);

    hN.addInputPort('Sign');
    Sign_s1=addSignal(hN,'Sign',pirTyp2,slRate);
    Sign_s1.addDriver(hN,1);

    hN.addOutputPort('SFIX');
    Delay8_out1_s8=addSignal(hN,'Delay8_out1',pirTyp3,slRate);
    Delay8_out1_s8.addReceiver(hN,0);

    DataTypeConversion2_out1_s2=addSignal(hN,'Data Type Conversion2_out1',pirTyp3,slRate);
    DataTypeConversion3_out1_s3=addSignal(hN,'Data Type Conversion3_out1',pirTyp4,slRate);
    Delay1_out1_s4=addSignal(hN,'Delay1_out1',pirTyp4,slRate);
    Delay2_out1_s5=addSignal(hN,'Delay2_out1',pirTyp1,slRate);
    Delay8_out1_s6=addSignal(hN,'Delay8_out1',pirTyp2,slRate);
    Switch1_out1_s7=addSignal(hN,'Switch1_out1',pirTyp4,slRate);
    UnaryMinus_out1_s8=addSignal(hN,'Unary Minus_out1',pirTyp4,slRate);

    pirelab.getIntDelayComp(hN,...
    Switch1_out1_s7,...
    Delay1_out1_s4,...
    pipestage(5),'Delay1',...
    fi(0,nt1,fiMath1,'hex','0000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    Mul_result_s0,...
    Delay2_out1_s5,...
    pipestage(4),'Delay2',...
    fi(0,nt2,fiMath1,'hex','000000000000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    Sign_s1,...
    Delay8_out1_s6,...
    pipestage(4),'Delay8',...
    fi(0,nt3,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getDTCComp(hN,...
    Delay1_out1_s4,...
    DataTypeConversion2_out1_s2,...
    rndMode,satMode,'RWV','Data Type Conversion2');

    pirelab.getDTCComp(hN,...
    Delay2_out1_s5,...
    DataTypeConversion3_out1_s3,...
    'Floor','Wrap','RWV','Data Type Conversion3');

    pirelab.getSwitchComp(hN,...
    [UnaryMinus_out1_s8,DataTypeConversion3_out1_s3],...
    Switch1_out1_s7,...
    Delay8_out1_s6,'Switch1',...
    '~=',0,'Floor','Wrap');

    pirelab.getUnaryMinusComp(hN,...
    DataTypeConversion3_out1_s3,...
    UnaryMinus_out1_s8,...
    'Wrap','Unary Minus');

    pirelab.getIntDelayComp(hN,...
    DataTypeConversion2_out1_s2,...
    Delay8_out1_s8,...
    pipestage(6),'Delay8',...
    fi(0,nt4,fiMath1,'hex','0000000000000000'),...
    0,0,[],0,0);

end

function hN=createNetwork_n1(p,hN,topNwkName,pipestage,slRate,WL,UWL,FL,guard,flGtZero)

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
    pirTyp5=pir_sfixpt_t(12,0);
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp2=pir_ufixpt_t(11,0);
    pirTyp3=pir_ufixpt_t(52,0);
    pirTyp6=pir_ufixpt_t(53,-52);
    pirTyp7=pir_ufixpt_t((WL+guard),-(FL+guard));

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);
    nt2=numerictype(0,11,0);
    nt3=numerictype(0,52,0);

    hN.addInputPort('XS');
    XS_s0=addSignal(hN,'XS',pirTyp1,slRate);
    XS_s0.addDriver(hN,0);

    hN.addInputPort('XE');
    XE_s1=addSignal(hN,'XE',pirTyp2,slRate);
    XE_s1.addDriver(hN,1);

    hN.addInputPort('XM');
    XM_s2=addSignal(hN,'XM',pirTyp3,slRate);
    XM_s2.addDriver(hN,2);

    hN.addOutputPort('SFIX');
    AddSign_out1_s3=addSignal(hN,'AddSign_out1',pirTyp4,slRate);
    AddSign_out1_s3.addReceiver(hN,0);

    Delay11_out1_s4=addSignal(hN,'Delay11_out1',pirTyp1,slRate);
    Delay3_out1_s5=addSignal(hN,'Delay3_out1',pirTyp2,slRate);
    Delay4_out1_s6=addSignal(hN,'Delay4_out1',pirTyp3,slRate);
    Delay5_out1_s7=addSignal(hN,'Delay5_out1',pirTyp1,slRate);
    x_ve_s9=addSignal(hN,'+ve',pirTyp5,slRate);
    ExponentBiasAndMantissa_out2_s10=addSignal(hN,'ExponentBiasAndMantissa_out2',pirTyp6,slRate);
    D_TO_FIX_out1_s11=addSignal(hN,'D_TO_FIX_out1',pirTyp7,slRate);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed/AddSign'));
    AddSign=hN.addComponent('ntwk_instance_comp',hRefN);
    AddSign.Name='AddSign';
    pirelab.connectNtwkInstComp(AddSign,...
    [D_TO_FIX_out1_s11,Delay11_out1_s4],...
    AddSign_out1_s3);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed/ExponentBias_and_Mantissa'));
    ExponentBias_And_Mantissa=hN.addComponent('ntwk_instance_comp',hRefN);
    ExponentBias_And_Mantissa.Name='ExponentBias_and_Mantissa';
    pirelab.connectNtwkInstComp(ExponentBias_And_Mantissa,...
    [Delay3_out1_s5,Delay4_out1_s6],...
    [x_ve_s9,ExponentBiasAndMantissa_out2_s10]);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed/D_TO_FIX'));
    D_TO_FIX=hN.addComponent('ntwk_instance_comp',hRefN);
    D_TO_FIX.Name='D_TO_FIX';
    pirelab.connectNtwkInstComp(D_TO_FIX,...
    [x_ve_s9,ExponentBiasAndMantissa_out2_s10],...
    D_TO_FIX_out1_s11);

    pirelab.getIntDelayComp(hN,...
    Delay5_out1_s7,...
    Delay11_out1_s4,...
    sum(pipestage(2:3)),'Delay11',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    XE_s1,...
    Delay3_out1_s5,...
    pipestage(1),'Delay3',...
    fi(0,nt2,fiMath1,'hex','000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    XM_s2,...
    Delay4_out1_s6,...
    pipestage(1),'Delay4',...
    fi(0,nt3,fiMath1,'hex','0000000000000'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hN,...
    XS_s0,...
    Delay5_out1_s7,...
    pipestage(1),'Delay5',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

end

function hN=createNetwork_n0(p,hN,topNwkName,slRate1,WL,UWL,FL,flGtZero)

    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(52,0);
    pirTyp2=pir_ufixpt_t(11,0);

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
    Convert_Double2Fixed_out1_s3=addSignal(hN,'Convert_Double2Fixed_out1',pirTyp4,slRate1);
    Convert_Double2Fixed_out1_s3.addReceiver(hN,0);

    hRefN=p.findNetwork('fullname',getSubNwkName(topNwkName,'Convert_Double2Fixed'));
    Convert_Double2Fixed=hN.addComponent('ntwk_instance_comp',hRefN);
    Convert_Double2Fixed.Name='Convert_Double2Fixed';
    pirelab.connectNtwkInstComp(Convert_Double2Fixed,...
    [In1_s0,In2_s1,In3_s2],...
    Convert_Double2Fixed_out1_s3);


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
