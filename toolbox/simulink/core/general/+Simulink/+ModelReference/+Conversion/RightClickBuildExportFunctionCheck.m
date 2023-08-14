classdef RightClickBuildExportFunctionCheck<Simulink.ModelReference.Conversion.SubsystemConversionCheck
    methods(Access=public)
        function this=RightClickBuildExportFunctionCheck(varargin)
            this@Simulink.ModelReference.Conversion.SubsystemConversionCheck(varargin{:});
            this.CheckModelForConversion=Simulink.ModelReference.Conversion.CheckModelForConversionRCB(this.ConversionData);
        end
    end
    methods(Access=protected)
        function checkNonBusSignalPassingMultiRates(this,currentSubsystem)
            nonbusSignalMultiRatesChecker=Simulink.ModelReference.Conversion.NonBusSignalPassingMultiRatesCheckerRCB(this.ConversionData,currentSubsystem);
            nonbusSignalMultiRatesChecker.check;
        end
        function checkExportedFunctionSubsystem(this,currentSubsystem)
            this.checkExportedFunctionSubsystemImpl(currentSubsystem);
        end

        function checkModelBeforeBuild(~,~)

        end

        function checkSubsystemType(this,currentSubsystem)
            checker=Simulink.ModelReference.Conversion.SubsystemTypeCheckerRCB(currentSubsystem,this.ConversionData);
            this.IsVirtualSubsystem(this.Systems==currentSubsystem)=checker.check();
        end

        function checkForConstInputs(~,~)

        end

        function checkUnappliedConfigSetChanges(this,subsysH)
            this.checkUnappliedConfigSetChangesImpl(subsysH);
        end

        function checkModelSettingsImpl(this)
            this.checkModelSettingsImplRCB;
        end

        function checkMaskedSubsystem(this)
            Simulink.ModelReference.Conversion.MaskedSubsystemCheck.checkRCB(this.ConversionData);
        end
        function checkStateflow(this)
            Simulink.ModelReference.Conversion.StateflowCheck.checkRCB(this.ConversionData);
        end

        function checkForActualSrcDstSampleTimes(this,currentSubsystem)
            checker=Simulink.ModelReference.Conversion.ActualSrcDstSampleTimesCheckerRCB(this.Systems,this.SubsystemPortBlocks,this.ConversionParameters,this.Logger,currentSubsystem);
            checker.checkForActualSrcDstSampleTimes;
        end
    end
end