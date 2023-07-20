classdef VariableDimensionPortsChecker<handle




    properties
        ConversionData;
Systems
SubsystemPortBlocks
currentSubsystem
    end
    methods(Access=public)
        function this=VariableDimensionPortsChecker(ConversionData,SubsystemPortBlocks,currentSubsystem)
            this.ConversionData=ConversionData;
            this.Systems=ConversionData.ConversionParameters.Systems;
            this.SubsystemPortBlocks=SubsystemPortBlocks;
            this.currentSubsystem=currentSubsystem;
        end

        function check(this)
            subsysIdx=find(this.Systems==this.currentSubsystem);
            portBlocks=this.SubsystemPortBlocks{subsysIdx};
            isEnabledSS=~isempty(portBlocks.enableBlksH.blocks);
            if isEnabledSS
                ssInBlkHs=this.SubsystemPortBlocks{subsysIdx}.inportBlksH.blocks;
                ssOutBlkHs=this.SubsystemPortBlocks{subsysIdx}.outportBlksH.blocks;
                this.checkForVariableInports(ssInBlkHs);
                this.checkForVariableOutports(ssOutBlkHs);
            end
        end
    end
    methods(Access=private)
        function checkForVariableInports(this,inportBlocks)
            numberOfInportBlocks=length(inportBlocks);
            for idx=1:numberOfInportBlocks
                phs=get_param(inportBlocks(idx),'PortHandles');
                hasVarDims=this.hasVarDims(phs.Outport);
                if hasVarDims
                    throw(MSLException(message('Simulink:modelReference:variableDimsNotAllowedOnInput',idx,...
                    this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
                end
            end
        end


        function checkForVariableOutports(this,outportBlocks)
            numberOfOutportBlocks=length(outportBlocks);
            for idx=1:numberOfOutportBlocks
                phs=get_param(outportBlocks(idx),'PortHandles');
                hasVarDims=this.hasVarDims(phs.Inport);
                if hasVarDims
                    throw(MSLException(message('Simulink:modelReference:variableDimsNotAllowedOnOutput',idx,...
                    this.ConversionData.beautifySubsystemName(this.currentSubsystem))));
                end
            end
        end

        function hasVD=hasVarDims(this,portHandle)
            hasVD=false;
            bus=get_param(portHandle,'CompiledBusStruct');
            if~isempty(bus)
                busName=get_param(portHandle,'CompiledPortAliasedThruDataType');
                hasVD=this.checkBusVariableDimensionsMode(this.ConversionData.DataAccessor,busName,portHandle);
            else
                dimsMode=get_param(portHandle,'CompiledPortDimensionsMode');
                if any(dimsMode)
                    hasVD=true;
                end
            end
        end
    end

    methods(Static,Access=public)
        function hasVarDims=checkBusVariableDimensionsMode(dataAccessor,busName,portHandle)
            hasVarDims=false;

            busObject=Simulink.ModelReference.Conversion.getBusObjectFromName(busName,false,dataAccessor);
            if~isempty(busObject)
                numberOfBusElements=length(busObject.Elements);
                for elIdx=1:numberOfBusElements
                    busElm=busObject.Elements(elIdx);
                    dtypeIsABus=~isempty(Simulink.ModelReference.Conversion.getBusObjectFromName(busElm.DataType,false,dataAccessor));
                    if dtypeIsABus
                        hasVarDims=Simulink.ModelReference.Conversion.VariableDimensionPortsChecker.checkBusVariableDimensionsMode(dataAccessor,busElm.DataType,portHandle);
                        return;
                    else
                        if strcmp(busElm.DimensionsMode,'Variable')
                            hasVarDims=true;
                            return;
                        end
                    end
                end
            else
                dimsMode=get_param(portHandle,'CompiledPortDimensionsMode');
                if any(dimsMode)
                    hasVarDims=true;
                    return;
                end
            end
        end

        function checkAndThrowErrorForVardim(blk,portInfo)




            if slfeature('BEPAtRootVarDimsSupport')==0
                isBEP=Simulink.ModelReference.Conversion.isBusElementPort(blk);
                if isBEP&&strcmpi(portInfo.DimensionsMode,'Variable')
                    throw(MSLException(message('Simulink:BusElPorts:VarDimsNotSupportedRoot',...
                    get_param(blk,'Element'),get_param(blk,'PortName'))));
                end
            end
        end
    end
end


