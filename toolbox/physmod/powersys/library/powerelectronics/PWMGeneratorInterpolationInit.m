function[NumberOfPulses,NumberOfArms,Vref_PortDim,NumberOfCarriers,Kin,...
    ADDin,Pselect_Index,Pselect_PortSize,WantBlockChoice]...
    =PWMGeneratorInterpolationInit(GeneratorType,Ts,Fc)

    if Ts<=0
        error(message('physmod:powersys:common:GreaterThan',gcb,'Sample time','0'));
    end

    if Fc<=0
        error(message('physmod:powersys:common:GreaterThan',gcb,'Carrier frequency','0'));
    end

    switch GeneratorType

    case 'Two-quadrant'
        NumberOfPulses=2;
        NumberOfArms=1;
        Vref_PortDim=1;
        NumberOfCarriers=1;
        Kin=[2];
        ADDin=-1;
        Pselect_Index=[1,2];
        Pselect_PortSize=NumberOfPulses;
        WantBlockChoice='PWMgenInterp_123arms';

    case 'Full-bridge, single phase'
        NumberOfPulses=4;
        NumberOfArms=2;
        Vref_PortDim=1;
        NumberOfCarriers=1;
        Kin=[1,-1];
        ADDin=0;
        Pselect_Index=[1,3,2,4];
        Pselect_PortSize=NumberOfPulses;
        WantBlockChoice='PWMgenInterp_123arms';

    case 'Two-level, three-phase'
        NumberOfPulses=6;
        NumberOfArms=3;
        Vref_PortDim=3;
        NumberOfCarriers=1;
        Kin=[1,1,1];
        ADDin=0;
        Pselect_Index=[1,4,2,5,3,6];
        Pselect_PortSize=NumberOfPulses;
        WantBlockChoice='PWMgenInterp_123arms';

    case 'Three-level, three-phase'
        NumberOfPulses=12;
        NumberOfArms=3;
        Vref_PortDim=3;
        NumberOfCarriers=2;
        Kin=[1,1,1];
        ADDin=0;
        Pselect_Index=[1:12];
        Pselect_PortSize=NumberOfPulses;
        WantBlockChoice='PWMgenInterp_3Level';
    end