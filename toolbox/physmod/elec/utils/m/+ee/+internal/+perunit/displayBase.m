function displayBase(b)%#codegen




    coder.allowpcode('plain');

    ee.internal.displayField(b,'SRated','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_RatedApparentPower')));
    ee.internal.displayField(b,'VRated','V',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_RatedVoltage')));
    ee.internal.displayField(b,'FRated','Hz',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_RatedElectricalFrequency')));
    ee.internal.displayField(b,'connection','',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_ConnectionConfiguration')));
    ee.internal.displayField(b,'SPerPhase','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_ApparentPowerPerPhase')));
    ee.internal.displayField(b,'PPerPhase','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_RealPowerPerPhase')));
    ee.internal.displayField(b,'QPerPhase','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_ReactivePowerPerPhase')));
    ee.internal.displayField(b,'V','V',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_RMSVoltage')));
    ee.internal.displayField(b,'v','V',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_InstantaneousVoltage')));
    ee.internal.displayField(b,'I','A',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_RMSCurrent')));
    ee.internal.displayField(b,'i','A',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_InstantaneousCurrent')));
    ee.internal.displayField(b,'Z','Ohm',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Impedance')));
    ee.internal.displayField(b,'R','Ohm',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Resistance')));
    ee.internal.displayField(b,'X','Ohm',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Reactance')));
    ee.internal.displayField(b,'Y','S',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Admittance')));
    ee.internal.displayField(b,'G','S',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Conductance')));
    ee.internal.displayField(b,'B','S',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Susceptance')));
    ee.internal.displayField(b,'L','H',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Inductance')));
    ee.internal.displayField(b,'C','F',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_Capacitance')));
    ee.internal.displayField(b,'Psi','Wb',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_RMSMagneticFluxLinkage')));
    ee.internal.displayField(b,'psi','Wb',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_InstantaneousPeakMagneticFluxLinkage')));
    ee.internal.displayField(b,'wElectrical','rad/s',getString(message('physmod:ee:library:comments:utils:perunit:displayBase:sprintf_ElectricalAngularSpeed')));
end

