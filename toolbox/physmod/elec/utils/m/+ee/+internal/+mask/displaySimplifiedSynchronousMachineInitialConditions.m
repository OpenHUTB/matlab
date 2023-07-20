function displaySimplifiedSynchronousMachineInitialConditions(blockName,ic)




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

        fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_InitialConditionsRequiredForSteadystate')));
        ee.internal.displayField(ic,'si_Emag0','V',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_InternalGeneratedVoltage')));
        ee.internal.displayField(ic,'pu_Emag0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_InternalGeneratedVoltage')));
        ee.internal.displayField(ic,'si_torque0','Nm',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_MechanicalTorque')));
        ee.internal.displayField(ic,'pu_torque0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_MechanicalTorque')));
        ee.internal.displayField(ic,'si_Pm0','W',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_MechanicalPower')));
        ee.internal.displayField(ic,'pu_Pm0','pu',getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_MechanicalPower')));
    else

        fprintf(getString(message('physmod:ee:library:comments:utils:mask:displaySynchronousMachineInitialConditions:sprintf_AssociatedInitialConditionsAreOnlyAvailableIfMaskParame')));
    end

end
