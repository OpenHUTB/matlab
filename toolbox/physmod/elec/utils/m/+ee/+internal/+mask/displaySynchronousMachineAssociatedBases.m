function displaySynchronousMachineAssociatedBases(blockName,baseValues)




    ee.internal.mask.displayBlockName(blockName);

    fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineAssociatedBases:sprintf_RotorBaseValues')));
    ee.internal.displayField(baseValues.b,'wMechanical','rad/s',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineAssociatedBases:sprintf_MechanicalAngularSpeed')));
    ee.internal.displayField(baseValues.b,'torque','N*m',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineAssociatedBases:sprintf_Torque')));

    fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineAssociatedBases:sprintf_FieldCircuitBaseValuesEfdIfdexciterModelNonreciprocalPu')));
    ee.internal.displayField(baseValues.fd,'v','V',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineAssociatedBases:sprintf_InstantaneousVoltage')));
    ee.internal.displayField(baseValues.fd,'i','A',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineAssociatedBases:sprintf_InstantaneousCurrent')));

end