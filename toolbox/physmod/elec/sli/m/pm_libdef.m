function entry=pm_libdef




    entry=PmSli.LibraryEntry('ee_sl_lib','Power_System_Blocks','ee_lib');
    entry(end).Descriptor=sprintf('Control');
    entry(end).DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn('sps/index.html','sps/ref');
    entry(end).EditingModeFcn='ee_sli_editingmodecallback';

    entry=iAddEntry(entry,'eeAdaptiveController');
    entry=iAddEntry(entry,'eeAlternativeControllers');
    entry=iAddEntry(entry,'eeAsmCurrentController');
    entry=iAddEntry(entry,'eeAsmDirectTorqueControl');
    entry=iAddEntry(entry,'eeAsmDtcSvm');
    entry=iAddEntry(entry,'eeAsmFieldOrientedControl');
    entry=iAddEntry(entry,'eeAsmFluxObserver');
    entry=iAddEntry(entry,'eeAsmScalarControl');
    entry=iAddEntry(entry,'eeBldcCommutationLogic');
    entry=iAddEntry(entry,'eeBldcCurrentController');
    entry=iAddEntry(entry,'eeCycloconverterController');
    entry=iAddEntry(entry,'eeDcCurrentController');
    entry=iAddEntry(entry,'eeDcDcVoltageController');
    entry=iAddEntry(entry,'eeDcVoltageController');
    entry=iAddEntry(entry,'eeDiscretePi');
    entry=iAddEntry(entry,'eeDqVoltageLimiter');
    entry=iAddEntry(entry,'eeGeneralControl');
    entry=iAddEntry(entry,'eeGeneralMeasurement');
    entry=iAddEntry(entry,'eeGovernorG1');
    entry=iAddEntry(entry,'eeGovernorG3');
    entry=iAddEntry(entry,'eeHysteresisControl');
    entry=iAddEntry(entry,'eeLCFB1');
    entry=iAddEntry(entry,'eeLuenbergerObserver');
    entry=iAddEntry(entry,'eePowerMeasurement');
    entry=iAddEntry(entry,'eePmsmCurrentController');
    entry=iAddEntry(entry,'eePmsmCurrentReferenceGen');
    entry=iAddEntry(entry,'eePmsmFieldOrientedControl');
    entry=iAddEntry(entry,'eePmsmFwController');
    entry=iAddEntry(entry,'eePmsmTorqueEstimator');
    entry=iAddEntry(entry,'eePwmGenerator');
    entry=iAddEntry(entry,'eePwmGeneratorMultilevel');
    entry=iAddEntry(entry,'eePwmGeneratorTwoLevel');
    entry=iAddEntry(entry,'eePwmGeneratorThreeLevel');
    entry=iAddEntry(entry,'eePwmGeneratorViennaRectifier');
    entry=iAddEntry(entry,'eeQuadratureDecoder');
    entry=iAddEntry(entry,'eeResolverToDigitalConverter');
    entry=iAddEntry(entry,'eeRmsMeasurement');
    entry=iAddEntry(entry,'eeSinglePhaseAsmDTC');
    entry=iAddEntry(entry,'eeSinglePhaseAsmFOC');
    entry=iAddEntry(entry,'eeSinusoidalMeasurementV2');
    entry=iAddEntry(entry,'eeSinGeneratorThreePhase');
    entry=iAddEntry(entry,'eeSlidingModeController');
    entry=iAddEntry(entry,'eeSmAC1C');
    entry=iAddEntry(entry,'eeSmAC2C');
    entry=iAddEntry(entry,'eeSmAC3C');
    entry=iAddEntry(entry,'eeSmAC4C');
    entry=iAddEntry(entry,'eeSmAC5C');
    entry=iAddEntry(entry,'eeSmAC6C');
    entry=iAddEntry(entry,'eeSmAC7C');
    entry=iAddEntry(entry,'eeSmAC8C');
    entry=iAddEntry(entry,'eeSmCurrentController');
    entry=iAddEntry(entry,'eeSmCurrentReferenceGen');
    entry=iAddEntry(entry,'eeSmDC1C');
    entry=iAddEntry(entry,'eeSmDC2C');
    entry=iAddEntry(entry,'eeSmDC4C');
    entry=iAddEntry(entry,'eeSmFieldOrientedControl');
    entry=iAddEntry(entry,'eeSmGovernor');
    entry=iAddEntry(entry,'eeSmPSS1A');
    entry=iAddEntry(entry,'eeSmPSS2C');
    entry=iAddEntry(entry,'eeSmPSS7C');
    entry=iAddEntry(entry,'eeSmST1C');
    entry=iAddEntry(entry,'eeSmST2C');
    entry=iAddEntry(entry,'eeSmST3C');
    entry=iAddEntry(entry,'eeSmST4C');
    entry=iAddEntry(entry,'eeSrmCommutationLogic');
    entry=iAddEntry(entry,'eeSrmCurrentController');
    entry=iAddEntry(entry,'eeStairGenerator');
    entry=iAddEntry(entry,'eeThyristorRectifierControl');
    entry=iAddEntry(entry,'eeThyristorSixPulseGenerator');
    entry=iAddEntry(entry,'eeThyristorTwelvePulseGenerator');
    entry=iAddEntry(entry,'eeTotalHarmonicDistorsion');
    entry=iAddEntry(entry,'eeTransforms');
    entry=iAddEntry(entry,'eeVelocityController');
    entry=iAddEntry(entry,'eeSequenceAnalyzer');
    entry=iAddEntry(entry,'eePMU');
    entry=iAddEntry(entry,'eeProgrammableSignalGenerator');
end

function entry=iAddEntry(entry,libraryName)
    entry(end+1)=PmSli.LibraryEntry(libraryName,'Power_System_Blocks','');
    entry(end).DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn('sps/index.html','sps/ref');
    entry(end).EditingModeFcn='ee_sli_editingmodecallback';
end