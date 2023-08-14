function[Ts,WantBlockChoice,VariationType,SinglePhase,MagnitudeVps,PhaseVps,FreqVps,VariationStep,VariationRate,...
    VariationMagnitude,Ton_Variation,Toff_Variation,n_HarmoA,n_HarmoB,Mag_HarmoA,Phase_HarmoA,Seq_HarmoA,...
    Mag_HarmoB,Phase_HarmoB,Seq_HarmoB,Ton_Harmo,Toff_Harmo,TimeValues,Amplitudes,vec_dt]=ThreePhaseProgSourceInit(block,...
    PositiveSequence,VariationEntity,VariationType,VariationTypeAlt,VariationStep,VariationRate,VariationMagnitude,VariationTiming,TimeValues,HarmonicA,HarmonicB,Timing,Amplitudes)






    switch VariationEntity
    case{3,4}
        VariationType=VariationTypeAlt;
    end


    SinglePhase=0;


    MagnitudeVps=PositiveSequence(1)*sqrt(2/3);
    PhaseVps=PositiveSequence(2);
    FreqVps=PositiveSequence(3);


    HarmonicA(2)=HarmonicA(2)*MagnitudeVps;
    HarmonicB(2)=HarmonicB(2)*MagnitudeVps;


    if VariationEntity==2
        VariationStep=VariationStep*MagnitudeVps;
        VariationRate=VariationRate*MagnitudeVps;
        VariationMagnitude=VariationMagnitude*MagnitudeVps;
        Amplitudes=Amplitudes*MagnitudeVps;
    end


    Ton_Variation=VariationTiming(1);
    Toff_Variation=VariationTiming(2);

    n_HarmoA=HarmonicA(1);
    Mag_HarmoA=HarmonicA(2);
    Phase_HarmoA=HarmonicA(3);
    Seq_HarmoA=HarmonicA(4);
    if n_HarmoA==0
        Phase_HarmoA=90;
        Seq_HarmoA=0;
    end

    n_HarmoB=HarmonicB(1);
    Mag_HarmoB=HarmonicB(2);
    Phase_HarmoB=HarmonicB(3);
    Seq_HarmoB=HarmonicB(4);
    if n_HarmoB==0
        Phase_HarmoB=90;
        Seq_HarmoB=0;
    end

    Ton_Harmo=Timing(1);
    Toff_Harmo=Timing(2);

    if TimeValues(1)~=0,
        TimeValues=[0,TimeValues];
        Amplitudes=[0,Amplitudes];
    end

    n=length(TimeValues);
    vec_dt=[TimeValues,0]-[0,TimeValues];
    vec_dt=vec_dt(2:n);

    powericon('psbloadfunction',block,'goto','Initialize');

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        WantBlockChoice='Phasor';
    end
    if PowerguiInfo.DiscretePhasor
        WantBlockChoice='Discrete Phasor';
    end
    if PowerguiInfo.Discrete
        WantBlockChoice='Discrete';
    end
    if PowerguiInfo.Continuous
        WantBlockChoice='Continuous';
    end