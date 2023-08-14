classdef FunctionCallSubsystemChecker<Simulink.ModelReference.Conversion.Checker




    properties
ConversionData
currentSubsystem
SubsystemPortBlocks
Systems
    end

    methods(Access=public)
        function this=FunctionCallSubsystemChecker(ConversionData,SubsystemPortBlocks,currentSubsystem)
            this@Simulink.ModelReference.Conversion.Checker(ConversionData.ConversionParameters,ConversionData.Logger);
            this.ConversionData=ConversionData;
            this.Systems=ConversionData.ConversionParameters.Systems;
            this.currentSubsystem=currentSubsystem;
            this.SubsystemPortBlocks=SubsystemPortBlocks;
        end

        function check(this)
            this.checkForFcnCallsWithInheritStateSetting;
            this.checkForFcnCallOutputs;
            this.checkForWideFcnCallPort;
        end
    end
    methods(Access=private)
        function checkForFcnCallsWithInheritStateSetting(this)



            compiledInfo=get_param(this.currentSubsystem,'CompiledRTWSystemInfo');



            if isempty(compiledInfo)
                return;
            end
            ss=compiledInfo(7);
            if ishandle(ss)
                throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidSubsystemFcnCallSSWithInheritState',...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(ss),ss),...
                this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
            end
        end

        function checkForFcnCallOutputs(this)
            subsysIdx=this.Systems==this.currentSubsystem;
            outportBlks=this.SubsystemPortBlocks{subsysIdx}.outportBlksH.blocks;
            portDataTypes=get_param(this.currentSubsystem,'CompiledPortDataTypes');
            outDataTypes=portDataTypes.Outport;
            numberOfOutputDataTypes=length(outDataTypes);
            for idx=1:numberOfOutputDataTypes
                if strcmp(outDataTypes(idx),'fcn_call')
                    portBlkName=get_param(outportBlks(idx),'PortName');
                    throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidSubsystemFcnCallOutput',portBlkName)));
                end
            end
        end

        function checkForWideFcnCallPort(this)
            ssType=Simulink.SubsystemType(this.currentSubsystem);
            if ssType.isFunctionCallSubsystem
                portHs=get_param(this.currentSubsystem,'PortHandles');
                portWidth=get_param(portHs.Trigger,'CompiledPortWidth');
                if~isempty(portWidth)&&portWidth>1
                    this.handleDiagnostic(message('Simulink:modelReference:convertToModelReference_InvalidSubsystemWideFcnCallPort',portWidth));
                end
            end
        end

    end
end


