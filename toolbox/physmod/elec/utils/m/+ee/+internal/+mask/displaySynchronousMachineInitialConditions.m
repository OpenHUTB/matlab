function displaySynchronousMachineInitialConditions(blockName,ic)




    ee.internal.mask.displayBlockName(blockName);

    if~isnan(ic.si_Vmag0)
        fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_InitialMachineStateAndOutput')));
        ee.internal.displayField(ic,'pu_Pt0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_RealPower'))');
        ee.internal.displayField(ic,'pu_Qt0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_ReactivePower')));
        ee.internal.displayField(ic,'pu_Vmag0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_TerminalVoltageMagnitude')));
        ee.internal.displayField(ic,'pu_It0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_TerminalCurrent')));
        ee.internal.displayField(ic,'phi0','rad',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_PowerFactorAngle')));
        ee.internal.displayField(ic,'phi0_deg','deg',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_PowerFactorAngle')));
        ee.internal.displayField(ic,'delta0','rad',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_LoadAngle')));
        ee.internal.displayField(ic,'delta0_deg','deg',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_LoadAngle')));

        fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_InitialConditionsRequiredForSteadystateSI')));
        ee.internal.displayField(ic,'si_efd0','V',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_FieldCircuitVoltage')));
        ee.internal.displayField(ic,'si_ifd0','A',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_FieldCircuitCurrent')));
        ee.internal.displayField(ic,'si_torque0','Nm',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_MechanicalTorque')));
        ee.internal.displayField(ic,'si_Pm0','W',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_MechanicalPower')));

        fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_RotorInitialConditions')));
        ee.internal.displayField(ic,'pu_torque0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_MechanicalTorque')));

        fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_FieldCircuitInitialConditionsexciterModelNonreciprocalP')));
        ee.internal.displayField(ic,'pu_fd_Efd0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_FieldVoltageFieldCircuitBase')));
        ee.internal.displayField(ic,'pu_fd_Ifd0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_FieldCurrentFieldCircuitBase')));
    else

        fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_AssociatedInitialConditionsAreOnlyAvailableIfMaskParame')));
    end

end
