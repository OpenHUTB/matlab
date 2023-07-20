classdef SubsystemTypeChecker<handle




    properties
ConversionData
ConversionParameters
currentSubsystem
    end

    methods(Access=public)
        function this=SubsystemTypeChecker(currentSubsystem,ConversionData)
            this.currentSubsystem=currentSubsystem;
            this.ConversionData=ConversionData;
            this.ConversionParameters=ConversionData.ConversionParameters;
        end

        function results=check(this)
            results=false;
            ssType=Simulink.SubsystemType(this.currentSubsystem);
            if~ssType.isSubsystem
                throw(MException(message('Simulink:modelReferenceAdvisor:invalidSSType',...
                this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
            end

            if ssType.isPhysmodSubsystem
                throw(MException(message('Simulink:modelReferenceAdvisor:invalidSSTypePhysMod',...
                this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
            end

            if ssType.isEnabledSubsystem||ssType.isTriggeredSubsystem||ssType.isEnabledAndTriggeredSubsystem
                if strcmp(get_param(this.currentSubsystem,'ShowSubsystemReinitializePorts'),'on')
                    throw(MException(message('Simulink:modelReferenceAdvisor:invalidSSWithReinitializeAndControlPorts',...
                    this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
                end
            end

            if ssType.isVariantSubsystem||ssType.isForIteratorSubsystem||ssType.isWhileIteratorSubsystem
                this.ConversionParameters.CreateBusObjectsForAllBuses=true;
            elseif(ssType.isTriggeredSubsystem||ssType.isFunctionCallSubsystem||...
                ssType.isAtomicSubsystem||ssType.isEnabledSubsystem||ssType.isEnabledAndTriggeredSubsystem||...
                ssType.isSimulinkFunction||ssType.isIteratorSubsystem||ssType.isStateflowSubsystem)

                if ssType.isTriggeredSubsystem||ssType.isFunctionCallSubsystem||...
                    ssType.isEnabledSubsystem||ssType.isEnabledAndTriggeredSubsystem
                    this.ConversionParameters.CreateBusObjectsForAllBuses=true;
                end



                if ssType.isFunctionCallSubsystem
                    functionCallPortBlock=find_system(this.currentSubsystem,'SearchDepth','1','BlockType','TriggerPort');
                    if strcmp(get_param(functionCallPortBlock,'ShowOutputPort'),'on')
                        throw(MException(message('Simulink:modelReferenceAdvisor:functionCallPortContainsOutput',...
                        this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
                    end
                end

                this.throwIfResettableSubsystem(ssType);
            elseif ssType.isResettableSubsystem
                this.throwIfResettableSubsystem(ssType);
            elseif ssType.isActionSubsystem
                throw(MException(message('Simulink:modelReferenceAdvisor:invalidSSTypeAction',...
                this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
            elseif ssType.isVirtualSubsystem
                results=true;
            else
                assert(false,'Unknown subsystem type: ''%s''',ssType.getType);
            end
        end
    end

    methods(Access=protected)
        function throwIfResettableSubsystem(this,ssType)
            if ssType.isResettableSubsystem
                throw(MException(message('Simulink:modelReferenceAdvisor:invalidSSTypeResettable',...
                this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
            end
        end
    end
end
