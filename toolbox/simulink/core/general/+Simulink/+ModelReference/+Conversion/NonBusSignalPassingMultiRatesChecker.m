classdef NonBusSignalPassingMultiRatesChecker<Simulink.ModelReference.Conversion.Checker




    properties
ConversionData
currentSubsystem
    end

    methods(Access=protected)
        function checkImpl(~)


        end
    end

    methods(Access=public)
        function this=NonBusSignalPassingMultiRatesChecker(ConversionData,currentSubsystem)
            this@Simulink.ModelReference.Conversion.Checker(ConversionData.ConversionParameters,ConversionData.Logger);
            this.ConversionData=ConversionData;
            this.currentSubsystem=currentSubsystem;
        end

        function check(this)
            this.checkImpl;
        end
    end
end
