classdef RightClickBuildCheck<Simulink.ModelReference.Conversion.SubsystemConversionCheck
    methods(Access=public)
        function this=RightClickBuildCheck(varargin)
            this@Simulink.ModelReference.Conversion.SubsystemConversionCheck(varargin{:});
            this.CheckModelForConversion=Simulink.ModelReference.Conversion.CheckModelForConversionRCB(this.ConversionData);
        end
    end

    methods(Access=protected)
        function checkNonBusSignalPassingMultiRates(this,currentSubsystem)
            nonbusSignalMultiRatesChecker=Simulink.ModelReference.Conversion.NonBusSignalPassingMultiRatesCheckerRCB(this.ConversionData,currentSubsystem);
            nonbusSignalMultiRatesChecker.check;
        end

        function checkModelBeforeBuild(~,block_hdl)
            Simulink.ModelReference.Conversion.SubsystemConversionCheck.checkModelBeforeBuildStatic(block_hdl);
        end

        function checkSubsystemType(this,currentSubsystem)
            checker=Simulink.ModelReference.Conversion.SubsystemTypeCheckerRCB(currentSubsystem,this.ConversionData);
            this.IsVirtualSubsystem(this.Systems==currentSubsystem)=checker.check();

            subsysIdx=find(this.Systems==currentSubsystem);
            if this.IsVirtualSubsystem(subsysIdx)&&~this.ConversionData.SkipVirtualSubsystemCheck
                if strcmp(get_param(currentSubsystem,'LinkStatus'),'resolved')
                    Simulink.ModelReference.Conversion.Utilities.breakLinks(currentSubsystem)
                end
                this.Logger.addWarning(message('Simulink:modelReferenceAdvisor:VirtualSubsystemRightClickBuild',getfullname(currentSubsystem)));
                set_param(currentSubsystem,'TreatAsAtomicUnit','on');
            end
        end

        function correctMustCopySubsystemSetting(this,currentSubsystem)
            mustCopySubsystemBlockChecker=Simulink.ModelReference.Conversion.MustCopySubsystemSettingChecker(this.ConversionData,currentSubsystem);
            mustCopySubsystemBlockChecker.check;
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