classdef AbstractBusElementPort<handle




    properties(Constant,Access=protected)
        BlockProperties={'OutDataTypeStr','PortDimensions','SampleTime',...
        'OutMin','OutMax','Unit','SampleTime','VarSizeSig','SignalType'};
    end

    methods(Abstract,Static)
        cachedPortInfo=cachePortInfo(blockMapping);
        restoreCachedPortInfo(bep,cachedPortInfo);

        createDefaultMapping(blkH);
        applyMapping(blkH,portMapping);
        updateMappingForElementNameChange(blockMapping,portMappings,newElementName);
        updateMappingForPortNameChange(blkH,portMappings,newPortName);

        elementName=getMappedElementName(mappedTo);

        setMessageQueueProperties(blkH);

        isQoSPort=isQoSPort(blockMapping);

        isMsgPort=isMessagePort(blockMapping);
    end

    methods(Static)

        function busElementPort=BusElementPortFactory(modelName)



            if Simulink.CodeMapping.isMappedToAutosarComponent(modelName)
                busElementPort=autosar.simulink.bep.ClassicBusElementPort();
            elseif Simulink.CodeMapping.isMappedToAdaptiveApplication(modelName)
                busElementPort=autosar.simulink.bep.AdaptiveBusElementPort();
            else
                assert(false,'Did not expect to get here');
            end
        end

        function cachedPortInfo=cacheBlockProperties(blk,cachedPortInfo)

            blockProperties=autosar.simulink.bep.AbstractBusElementPort.BlockProperties;
            for i=1:length(blockProperties)
                prop=blockProperties{i};
                cachedPortInfo.(prop)=get_param(blk,prop);
            end

        end

        function restoreBlockProperties(blockPath,cachedInfo)
            import autosar.simulink.bep.AbstractBusElementPort.*

            blockProperties=autosar.simulink.bep.AbstractBusElementPort.BlockProperties;
            paramValuePair={};
            for i=1:length(blockProperties)
                prop=blockProperties{i};
                paramValuePair{end+1}=prop;%#ok<AGROW>
                paramValuePair{end+1}=cachedInfo.(prop);%#ok<AGROW>
            end


            dataTypePair=extractNameValuePair(paramValuePair,'OutDataTypeStr');
            isSettingDataType=~isempty(dataTypePair);
            if isSettingDataType
                dataType=dataTypePair{end};
            else
                dataType=get_param(blockPath,'OutDataTypeStr');
            end
            isBusDefined=startsWith(dataType,'Bus:');

            if isBusDefined
                if isSettingDataType

                    set_param(blockPath,dataTypePair{:});
                end
                if slfeature('CompositePortsNonvirtualBusSupport')>0...
                    &&slfeature('AUTOSARBepNvBus')>0
                    autosar.simulink.bep.Utils.setParam(blockPath,false,'Virtuality','nonvirtual');
                    dimsAndSampleTimePairs=[extractNameValuePair(paramValuePair,'PortDimensions')...
                    ,extractNameValuePair(paramValuePair,'SampleTime')];
                    if~isempty(dimsAndSampleTimePairs)



                        set_param(blockPath,dimsAndSampleTimePairs{:});
                    end
                end
            else
                set_param(blockPath,paramValuePair{:});
            end

        end

        function nameValue=extractNameValuePair(nameValuePairsCell,name)
            nameValue={};
            idx=find(strcmp(nameValuePairsCell,name));
            if~isempty(idx)
                nameValue=nameValuePairsCell(idx:idx+1);
            end
        end

        function bepMapping=getMatchingMappingforBlk(blkH,busPortMappings)



            busElementPort=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(bdroot(blkH));


            elementName=get_param(blkH,'Element');
            busPortMappings=busPortMappings(cellfun(@(x)strcmp(busElementPort.getMappedElementName(x),elementName),{busPortMappings.MappedTo}));
            if isempty(busPortMappings)
                bepMapping=busPortMappings;
                return;
            end


            busPortMappings=busPortMappings(arrayfun(@(x)~busElementPort.isQoSPort(x),busPortMappings));
            if isempty(busPortMappings)
                bepMapping=busPortMappings;
                return;
            end


            bepMapping=busPortMappings(1);
        end
    end

    methods(Static,Access=protected)
        function configureQueueForAUTOSAR(blkH,queueCapacityStr)


            assert(autosar.composition.Utils.isCompositeInportBlock(blkH),...
            'Should only call this for bus element in blocks');


            set_param(blkH,'DataMode','message');
            set_param(blkH,'MessageQueueUseDefaultAttributes','off');

            set_param(blkH,'MessageQueueCapacity',queueCapacityStr);
            set_param(blkH,'MessageQueueType','FIFO');
            set_param(blkH,'MessageQueueOverwriting','off');
        end
    end
end


