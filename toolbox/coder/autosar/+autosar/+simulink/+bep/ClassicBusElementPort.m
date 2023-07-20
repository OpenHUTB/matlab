classdef ClassicBusElementPort<autosar.simulink.bep.AbstractBusElementPort




    methods(Static)
        function cachedPortInfo=cachePortInfo(blockMapping)


            cachedPortInfo.Port=blockMapping.MappedTo.Port;
            cachedPortInfo.Element=blockMapping.MappedTo.Element;
            cachedPortInfo.DataAccessMode=blockMapping.MappedTo.DataAccessMode;


            cachedPortInfo=...
            autosar.simulink.bep.AbstractBusElementPort.cacheBlockProperties(...
            blockMapping.Block,cachedPortInfo);


            cachedPortInfo.QueueCapacity=...
            autosar.simulink.bep.ClassicBusElementPort.getQueueLengthFromComSpec(...
            blockMapping);
        end

        function restoreCachedPortInfo(blockPath,cachedPortInfo)

            slMapping=autosar.api.getSimulinkMapping(bdroot(blockPath));
            slPortName=get_param(blockPath,'Name');

            isInport=strcmp(get_param(blockPath,'BlockType'),'Inport');
            if isInport
                slMapping.mapInport(slPortName,cachedPortInfo.Port,cachedPortInfo.Element,...
                cachedPortInfo.DataAccessMode);
            else
                slMapping.mapOutport(slPortName,cachedPortInfo.Port,cachedPortInfo.Element,...
                cachedPortInfo.DataAccessMode);
            end


            autosar.simulink.bep.AbstractBusElementPort.restoreBlockProperties(...
            blockPath,cachedPortInfo);

            if autosar.composition.Utils.isCompositeInportBlock(blockPath)&&...
                ~isempty(cachedPortInfo.QueueCapacity)

                autosar.simulink.bep.AbstractBusElementPort.configureQueueForAUTOSAR(...
                blockPath,cachedPortInfo.QueueCapacity);
            end
        end

        function createDefaultMapping(blkH)


            [isValid,port]=autosar.simulink.bep.Mapping.portHasValidDataPortMapping(blkH);
            if~isValid
                return;
            end

            portName=get_param(blkH,'PortName');
            elementName=get_param(blkH,'Element');

            isInport=strcmp(get_param(blkH,'BlockType'),'Inport');
            if isInport
                dataAccessMode='ExplicitReceive';
            else
                dataAccessMode='ExplicitSend';
            end


            if autosar.simulink.bep.Utils.isRootPort(blkH)
                port.mapPortElement('','',dataAccessMode);
            else
                port.mapPortElement(portName,elementName,dataAccessMode);
            end

        end

        function applyMapping(blkH,bepMapping)


            [isValid,port]=autosar.simulink.bep.Mapping.portHasValidDataPortMapping(blkH);
            if~isValid
                return;
            end

            portName=bepMapping.MappedTo.Port;
            elementName=bepMapping.MappedTo.Element;
            dataAccessMode=bepMapping.MappedTo.DataAccessMode;


            if autosar.simulink.bep.Utils.isRootPort(blkH)
                port.mapPortElement('','',dataAccessMode);
            else
                port.mapPortElement(portName,elementName,dataAccessMode);
            end
        end

        function updateMappingForElementNameChange(blockMapping,portMappings,newElementName)

            if autosar.simulink.functionPorts.Utils.isClientServerPort(blockMapping.Block)


                return;
            end

            oldPort=blockMapping.MappedTo.Port;
            oldElement=blockMapping.MappedTo.Element;
            for portIdx=1:numel(portMappings)
                portMapping=portMappings(portIdx);
                if strcmp(portMapping.MappedTo.Port,oldPort)...
                    &&strcmp(portMapping.MappedTo.Element,oldElement)

                    elementName=newElementName;
                else
                    continue;
                end
                oldDataAccess=portMapping.MappedTo.DataAccessMode;
                portMapping.mapPortElement(oldPort,elementName,oldDataAccess);
            end
        end

        function updateMappingForPortNameChange(blkH,portMappings,newPortName)


            if autosar.simulink.functionPorts.Utils.isClientServerPort(blkH)


                return;
            end

            blockPath=getfullname(blkH);
            newElement=get_param(blkH,'Element');

            for portIdx=1:numel(portMappings)
                portMapping=portMappings(portIdx);
                if strcmp(portMapping.Block,blockPath)
                    elementName=newElement;
                else
                    elementName=portMapping.MappedTo.Element;
                end
                oldDataAccess=portMapping.MappedTo.DataAccessMode;
                portMapping.mapPortElement(newPortName,elementName,oldDataAccess);
            end
        end

        function elementName=getMappedElementName(mappedTo)
            if isa(mappedTo,'Simulink.AutosarTarget.PortElement')
                elementName=mappedTo.Element;
            else
                assert(false,'Unexpected mappedTo class');
            end
        end

        function isQoSPort=isQoSPort(blockMapping)

            dataAccessMode=blockMapping.MappedTo.DataAccessMode;
            isQoSPort=any(strcmp(dataAccessMode,{'ErrorStatus','IsUpdated'}));
        end

        function isMsgPort=isMessagePort(blockMapping)

            dataAccessMode=blockMapping.MappedTo.DataAccessMode;
            isMsgPort=any(strcmp(dataAccessMode,...
            {'QueuedExplicitReceive','EndToEndQueuedReceive',...
            'QueuedExplicitSend','EndToEndQueuedSend'}));
        end

        function setMessageQueueProperties(blkH)
            queueCapacityStr=...
            autosar.simulink.bep.ClassicBusElementPort.getQueueCapacityString(blkH);
            autosar.simulink.bep.AbstractBusElementPort.configureQueueForAUTOSAR(...
            blkH,queueCapacityStr);
        end

        function queueCapacityStr=getQueueCapacityString(blkH)



            assert(strcmp(get_param(blkH,'BlockType'),'Inport'),...
            'Can only get Queue Capacity for inports');
            mapping=autosar.api.Utils.modelMapping(bdroot(blkH));
            blockMapping=mapping.Inports.findobj('Block',getfullname(blkH));
            assert(~isempty(blockMapping),[getfullname(blkH),' is not a mapped port']);
            queueCapacityStr=...
            autosar.simulink.bep.ClassicBusElementPort.getQueueLengthFromComSpec(...
            blockMapping);
            if isempty(queueCapacityStr)
                queueCapacityStr=...
                num2str(autosar.ui.comspec.ComSpecPropertyHandler.DefaultQueueLength);
            end
        end
    end

    methods(Static,Access=private)
        function queueCapacity=getQueueLengthFromComSpec(blockMapping)

            queueCapacity='';
            isInport=strcmp(get_param(blockMapping.Block,'BlockType'),'Inport');
            if isInport
                m3iComp=autosar.api.Utils.m3iMappedComponent(bdroot(blockMapping.Block));
                portName=blockMapping.MappedTo.Port;
                elementName=blockMapping.MappedTo.Element;
                m3iComSpec=autosar.ui.comspec.ComSpecUtils.getM3IComSpec(...
                m3iComp,portName,elementName,...
                isInport);
                if~isempty(m3iComSpec)&&m3iComSpec.has('QueueLength')


                    queueCapacity=...
                    autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyValueStr(...
                    m3iComSpec,'QueueLength');
                end
            end
        end
    end
end


