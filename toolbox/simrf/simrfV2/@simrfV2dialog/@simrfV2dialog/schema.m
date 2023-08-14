function schema




    parentPkg=findpackage('Simulink');
    parent=findclass(parentPkg,'SLDialogSource');
    rfPackage=findpackage('simrfV2dialog');
    hThisClass=schema.class(rfPackage,'simrfV2dialog',parent);



    p=schema.prop(hThisClass,'Block','mxArray');
    p.SetFunction=@setBlock;

    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'simrfV2browsefile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'simrfV2expand');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'simrfV2polynumerialplot');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    if isempty(findtype('SimRFV2EnumsDefineBase'))
        schema.EnumType('SimRFV2EnumsDefineBase',{'Yes'});

        schema.EnumType('SimRFV2VoltageUnit',{'V','mV','kV'});

        schema.EnumType('SimRFV2CurrentUnit',{'A','mA','uA','kA'});

        schema.EnumType('SimRFV2FreqUnitType',{'Hz','kHz','MHz','GHz'});

        schema.EnumType('SimRFV2TimeUnitType',{'s','ms','us','ns'});

        schema.EnumType('SimRFV2PowerUnit',{'W','mW','dBW','dBm'});

        schema.EnumType('SimRFV2PowerGainUnit',{'dB','None'});

        schema.EnumType('SimRFV2ResistanceUnitType',{...
        'Ohm','kOhm','MOhm','GOhm'});

        schema.EnumType('SimRFV2InductanceUnitType',{'H','mH','uH','nH'});

        schema.EnumType('SimRFV2CapacitanceUnitType',{...
        'F','mF','uF','nF','pF'});

        schema.EnumType('SimRFV2TemperatureUnitType',{'C','Fh','K'});

        schema.EnumType('SimRFV2CWSourceType',{...
        'Ideal voltage','Ideal current','Power'});

        schema.EnumType('SimRFV2GatewayOutputFormat',{...
        'Complex Baseband',...
        'In-phase and Quadrature Baseband',...
        'Magnitude and Angle Baseband',...
        'Real Passband'});

        schema.EnumType('SimRFV2NonlinearDataMeasuredAt',{'Output','Input'});

        schema.EnumType('SimRFV2PolyDerivedFrom',{...
        'Even and odd order','Odd order'});

        schema.EnumType('SimRFV2AmplifierDataSourceType',{...
        'Data file','S-parameters'});

        schema.EnumType('SimRFV2AmplifierLinearGainDerivedFrom',{...
        'Available power gain',...
        'Open circuit voltage gain',...
'Data source'...
        ,'Polynomial coefficients',...
        'AM/AM-AM/PM table'});

        schema.EnumType('SimRFV2AmplifierImpedanceDerivedFrom',{...
        'User-specified','Data source'});

        schema.EnumType('SimRFV2MixerLinearGainDerivedFrom',{...
        'Available power gain','Open circuit voltage gain',...
        'Polynomial coefficients'});

        schema.EnumType('SimRFV2SparamRepresentationType',{...
        'Time domain (rationalfit)','Frequency domain'});

        schema.EnumType('SimRFV2LadderLCType',{...
        'LC Lowpass Tee','LC Lowpass Pi',...
        'LC Highpass Tee','LC Highpass Pi',...
        'LC Bandpass Tee','LC Bandpass Pi',...
        'LC Bandstop Tee','LC Bandstop Pi'});

        schema.EnumType('SimRFV2SourceType',{...
        'Ideal voltage','Ideal current'});

        schema.EnumType('SimRFV2NoiseType',{...
        'Noise figure','Spot noise data'});

        schema.EnumType('SimRFV2NoiseDistributionType',{...
        'White','Piece-wise linear','Colored'});

        schema.EnumType('SimRFV2PhaseUnitType',{'rad','deg'});

        schema.EnumType('SimRFV2FitOptType',{...
        'Share poles by columns','Share all poles','Fit individually'});

        schema.EnumType('SimRFV2PhaseShiftOptionType',...
        {'All carrier frequencies'});

        schema.EnumType('SimRFV2SolverType',{...
        'Auto','NDF2','Trapezoidal Rule','Backward Euler'});

        schema.EnumType('SimRFV2NewtonErrorEstimationType',{...
        '2-norm over all variables','Each variable separately'});

        schema.EnumType('SimRFV2NoiseBandwidthType',{...
        'Auto','Relative','Absolute'});

        schema.EnumType('SimRFV2DataSourceType',{...
        'Data file','Network-parameters','Rational model'});

        schema.EnumType('SimRFV2ParamType',{...
        'S-parameters','Y-parameters','Z-parameters'});

        schema.EnumType('SimRFV2FilterMethod',...
        {'Butterworth','Chebyshev','InverseChebyshev','Ideal'});







        schema.EnumType('SimRFV2FilterType',...
        {'Lowpass','Highpass','Bandpass','Bandstop'});

        schema.EnumType('SimRFV2FilterImplementation',...
        {'LC Tee','LC Pi','Transfer function'});

        schema.EnumType('SimRFV2FilterImplementationIdeal',...
        {'Constant per carrier','Frequency domain'});

        schema.EnumType('SimRFV2FilterImplementationRational',...
        {'Transfer function'});
    end


