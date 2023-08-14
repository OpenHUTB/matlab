function displayMachineInertiaParameters(blockName,parameters)




    ee.internal.mask.displayBlockName(blockName);

    ee.internal.perunit.displayMachineBase(parameters.b);

    fprintf(getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_MachineInertiaParameters')));
    ee.internal.displayField(parameters,'J','kg*m^2',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_ActualInertia')));
    ee.internal.displayField(parameters,'H','(W*s)/(V*A)',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_InertiaConstant')));
    ee.internal.displayField(parameters,'D','N*m/(rad/s)',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_DampingCoefficient')));
    ee.internal.displayField(parameters,'pu_D','1',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_PerUnitDampingCoefficient')));
    ee.internal.displayField(parameters,'pu_velocity0','1',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_InitialPerUnitVelocity')));
    ee.internal.displayField(parameters,'fElectrical0','Hz',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_InitialElectricalFrequency')));
    ee.internal.displayField(parameters,'fMechanical0','Hz',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_InitialMechanicalFrequency')));
    ee.internal.displayField(parameters,'wElectrical0','rad/s',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_InitialElectricalAngularVelocity')));
    ee.internal.displayField(parameters,'wMechanical0','rad/s',getString(message('physmod:ee:library:comments:utils:mask:displayMachineInertiaParameters:sprintf_InitialMechanicalAngularVelocity')));
    fprintf('\n');

end