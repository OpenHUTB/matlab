classdef AdaptiveBusElementPort<autosar.simulink.bep.AbstractBusElementPort




    methods(Static)
        function cachedPortInfo=cachePortInfo(blockMapping)


            cachedPortInfo.Port=blockMapping.MappedTo.Port;
            cachedPortInfo.Event=blockMapping.MappedTo.Event;
            if strcmp(get_param(blockMapping.Block,'BlockType'),'Outport')
                cachedPortInfo.AllocateMemory=blockMapping.MappedTo.AllocateMemory;
            end


            cachedPortInfo=...
            autosar.simulink.bep.AbstractBusElementPort.cacheBlockProperties(...
            blockMapping.Block,cachedPortInfo);
        end

        function restoreCachedPortInfo(blockPath,cachedInfo)

            slMapping=autosar.api.getSimulinkMapping(bdroot(blockPath));
            slPortName=get_param(blockPath,'Name');

            isInport=strcmp(get_param(blockPath,'BlockType'),'Inport');
            if isInport
                slMapping.mapInport(slPortName,cachedInfo.Port,cachedInfo.Event);
            else
                slMapping.mapOutport(slPortName,cachedInfo.Port,cachedInfo.Event,...
                cachedInfo.AllocateMemory);
            end


            autosar.simulink.bep.AbstractBusElementPort.restoreBlockProperties(...
            blockPath,cachedInfo);

            if autosar.composition.Utils.isCompositeInportBlock(blockPath)

                autosar.simulink.bep.AdaptiveBusElementPort.setMessageQueueProperties(...
                blockPath);
            end
        end

        function createDefaultMapping(blkH)


            [isValid,port]=autosar.simulink.bep.Mapping.portHasValidDataPortMapping(blkH);
            if~isValid
                return;
            end

            portName=get_param(blkH,'PortName');
            eventName=get_param(blkH,'Element');

            isRootPort=autosar.simulink.bep.Utils.isRootPort(blkH);

            isInport=strcmp(get_param(blkH,'BlockType'),'Inport');
            if isInport
                if isRootPort

                    port.mapPortEvent('','','');
                else
                    port.mapPortEvent(portName,eventName,'');
                end
            else
                allocateMemoryMode='false';
                if isRootPort

                    port.mapPortProvidedEvent('','',allocateMemoryMode,'');
                else
                    port.mapPortProvidedEvent(portName,eventName,...
                    allocateMemoryMode,'');
                end
            end
        end

        function applyMapping(blkH,portMapping)


            [isValid,port]=autosar.simulink.bep.Mapping.portHasValidDataPortMapping(blkH);
            if~isValid
                return;
            end

            portName=portMapping.MappedTo.Port;
            eventName=portMapping.MappedTo.Event;

            isInport=strcmp(get_param(portMapping.Block,'BlockType'),'Inport');
            if isInport
                if autosar.simulink.bep.Utils.isRootPort(blkH)

                    port.mapPortEvent('','','');
                else
                    port.mapPortEvent(portName,eventName,'');
                end
            else
                allocateMemoryMode=portMapping.MappedTo.AllocateMemory;
                if autosar.simulink.bep.Utils.isRootPort(blkH)

                    port.mapPortProvidedEvent('','',allocateMemoryMode,'');
                else
                    port.mapPortProvidedEvent(portName,eventName,allocateMemoryMode,'');
                end
            end
        end

        function updateMappingForElementNameChange(mapping,~,newElementName)

            if autosar.simulink.functionPorts.Utils.isClientServerPort(mapping.Block)
                oldPortName=mapping.MappedTo.Port;
                timeout=mapping.MappedTo.Timeout;
                fireAndForget='false';
                mapping.mapPortMethod(oldPortName,newElementName,timeout,...
                fireAndForget,'');
            else
                oldPortName=mapping.MappedTo.Port;

                isInport=strcmp(get_param(mapping.Block,'BlockType'),'Inport');
                if isInport
                    mapping.mapPortEvent(oldPortName,newElementName,'');
                else
                    oldMemoryAllocation=mapping.MappedTo.AllocateMemory;
                    mapping.mapPortProvidedEvent(oldPortName,newElementName,...
                    oldMemoryAllocation,'');
                end
            end
        end

        function updateMappingForPortNameChange(blkH,mappings,newPortName)

            blockPath=getfullname(blkH);

            if autosar.simulink.functionPorts.Utils.isClientServerPort(blkH)
                newMethod=get_param(blkH,'Element');
                for clientServerPortMapping=mappings
                    if strcmp(clientServerPortMapping.Block,blockPath)
                        methodName=newMethod;
                    else
                        methodName=clientServerPortMapping.MappedTo.Method;
                    end
                    timeout=clientServerPortMapping.MappedTo.Timeout;
                    fireAndForget='false';
                    clientServerPortMapping.mapPortMethod(newPortName,...
                    methodName,timeout,fireAndForget,'');
                end
            else
                newEvent=get_param(blkH,'Element');
                for portIdx=1:numel(mappings)
                    portMapping=mappings(portIdx);
                    if strcmp(portMapping.Block,blockPath)
                        eventName=newEvent;
                    else
                        eventName=portMapping.MappedTo.Event;
                    end
                    isInport=strcmp(get_param(blkH,'BlockType'),'Inport');
                    if isInport
                        portMapping.mapPortEvent(newPortName,eventName,'');
                    else
                        oldMemoryAllocation=portMapping.MappedTo.AllocateMemory;
                        portMapping.mapPortProvidedEvent(newPortName,eventName,...
                        oldMemoryAllocation,'');
                    end
                end
            end
        end

        function elementName=getMappedElementName(mappedTo)
            if isa(mappedTo,'Simulink.AutosarTarget.PortEvent')||...
                isa(mappedTo,'Simulink.AutosarTarget.PortProvidedEvent')
                elementName=mappedTo.Event;
            elseif isa(mappedTo,'Simulink.AutosarTarget.PortMethod')
                elementName=mappedTo.Method;
            else
                assert(false,'Unexpected mappedTo class');
            end
        end

        function isQoSPort=isQoSPort(~)

            isQoSPort=false;
        end

        function isMsgPort=isMessagePort(~)

            isMsgPort=true;
        end

        function setMessageQueueProperties(blkH)
            defaultQueueCapacityStr='1';
            autosar.simulink.bep.AbstractBusElementPort.configureQueueForAUTOSAR(...
            blkH,defaultQueueCapacityStr);
        end
    end
end


