function Base=BaseValues(NominalPower,NumberOfPhases,BaseVoltage)

    Base.Freq=2*pi*NominalPower(2);
    Base.Power=NominalPower(1)/NumberOfPhases;
    Base.Voltage=BaseVoltage;
    Base.Current=(Base.Power/Base.Voltage)*sqrt(2);
    Base.Flux=(Base.Voltage/Base.Freq)*sqrt(2);
    Base.Resistance=Base.Voltage^2/Base.Power;
    Base.Impedance=Base.Voltage^2/Base.Power/Base.Freq;