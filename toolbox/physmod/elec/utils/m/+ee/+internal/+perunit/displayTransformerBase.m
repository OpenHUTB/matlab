function displayTransformerBase(b)%#codegen




    coder.allowpcode('plain');

    fprintf(getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_TransformerBaseValues')));
    ee.internal.displayField(b,'SRated','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_RatedApparentPower')));
    ee.internal.displayField(b.winding(1),'SPerPhase','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_ApparentPowerPerPhase')));
    ee.internal.displayField(b.winding(1),'PPerPhase','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_RealPowerPerPhase')));
    ee.internal.displayField(b.winding(1),'QPerPhase','V*A',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_ReactivePowerPerPhase')));
    ee.internal.displayField(b,'FRated','Hz',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_RatedElectricalFrequency')));
    ee.internal.displayField(b.winding(1),'wElectrical','rad/s',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_ElectricalAngularSpeed')));

    for windingNo=1:size(b.winding,2)
        fprintf([' ',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Winding0numberinteger',windingNo))]);
        ee.internal.displayField(b.winding(windingNo),'VRated','V',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_RatedVoltage')));
        ee.internal.displayField(b.winding(windingNo),'connection','',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_ConnectionConfiguration')));
        ee.internal.displayField(b.winding(windingNo),'V','V',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_RMSVoltage')));
        ee.internal.displayField(b.winding(windingNo),'v','V',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_InstantaneousVoltage')));
        ee.internal.displayField(b.winding(windingNo),'I','A',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_RMSCurrent')));
        ee.internal.displayField(b.winding(windingNo),'i','A',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_InstantaneousCurrent')));
        ee.internal.displayField(b.winding(windingNo),'Z','Ohm',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Impedance')));
        ee.internal.displayField(b.winding(windingNo),'R','Ohm',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Resistance')));
        ee.internal.displayField(b.winding(windingNo),'X','Ohm',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Reactance')));
        ee.internal.displayField(b.winding(windingNo),'Y','S',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Admittance')));
        ee.internal.displayField(b.winding(windingNo),'G','S',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Conductance')));
        ee.internal.displayField(b.winding(windingNo),'B','S',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Susceptance')));
        ee.internal.displayField(b.winding(windingNo),'L','H',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Inductance')));
        ee.internal.displayField(b.winding(windingNo),'C','F',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_Capacitance')));
        ee.internal.displayField(b.winding(windingNo),'Psi','Wb',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_RMSMagneticFluxLinkage')));
        ee.internal.displayField(b.winding(windingNo),'psi','Wb',getString(message('physmod:ee:library:comments:utils:perunit:displayTransformerBase:sprintf_InstantaneousPeakMagneticFluxLinkage')));
    end
end

