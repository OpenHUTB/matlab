classdef LocalDworkCrossingChecker<Simulink.ModelReference.Conversion.Checker




    properties
ConversionData
currentSubsystem
    end
    methods(Access=public)
        function this=LocalDworkCrossingChecker(ConversionData,currentSubsystem)
            this@Simulink.ModelReference.Conversion.Checker(ConversionData.ConversionParameters,ConversionData.Logger);
            this.ConversionData=ConversionData;
            this.currentSubsystem=currentSubsystem;
        end

        function check(this)



            compiledInfo=get_param(this.currentSubsystem,'CompiledRTWSystemInfo');




            if~isempty(compiledInfo)
                bit1=bitand(compiledInfo(5),2);
                if bit1
                    this.handleDiagnostic(message('Simulink:modelReference:convertToModelReference_InvalidSubsystemDWorkCrossSys',...
                    this.ConversionData.beautifySubsystemName(this.currentSubsystem)));
                end
            end
        end
    end
end


