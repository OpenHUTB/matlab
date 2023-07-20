classdef ConstInputChecker<handle




    properties
ConversionData
ConversionParameters
Systems
currentSubsystem
SubsystemPortBlocks
Logger
    end
    methods(Access=public)
        function this=ConstInputChecker(ConversionData,SubsystemPortBlocks,currentSubsystem)
            this.ConversionData=ConversionData;
            this.ConversionParameters=ConversionData.ConversionParameters;
            this.Systems=ConversionData.ConversionParameters.Systems;
            this.currentSubsystem=currentSubsystem;
            this.SubsystemPortBlocks=SubsystemPortBlocks;
            this.Logger=ConversionData.Logger;
        end

        function check(this)
            subsysIdx=this.Systems==this.currentSubsystem;
            inBlkHs=this.SubsystemPortBlocks{subsysIdx}.inportBlksH.blocks;
            numberOfBlocks=length(inBlkHs);
            for inIdx=1:numberOfBlocks
                if this.isConstantSampleTime(get_param(inBlkHs(inIdx),'CompiledSampleTime'))
                    portName=get_param(inBlkHs(inIdx),'PortName');
                    if Simulink.ModelReference.Conversion.isBusElementPort(inBlkHs(inIdx))
                        elementName=get_param(inBlkHs(inIdx),'Element');
                        if~isempty(elementName)
                            portName=[portName,'.',elementName];%#ok
                        end
                    end
                    this.Logger.addWarning(message('Simulink:modelReference:convertToModelReference_InvalidSubsystemConstInput',portName));
                end
            end
        end
    end
    methods(Access=private)
        function status=isConstantSampleTime(~,ts)
            status=~iscell(ts)&&isinf(ts(1))&&(isinf(ts(2))||ts(2)==0);
        end
    end
end
