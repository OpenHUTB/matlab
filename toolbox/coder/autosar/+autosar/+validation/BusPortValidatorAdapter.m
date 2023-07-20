classdef BusPortValidatorAdapter<autosar.validation.PhasedValidator





    properties(Access=protected)
        ModelH;
    end

    properties(Abstract,Constant,Access=protected)
        ElementPropName;
        AccessModePropName;
    end

    methods(Access=protected)
        function verifyInitial(this,hModel)
            this.ModelH=hModel;
            this.verifyCompositePortMapping();
        end

        function verifyPostProp(this,hModel)
            this.verifyMessageQueueConfiguration(hModel);
        end
    end

    methods(Abstract,Static,Access=protected)

        verifyCompositePortMapping();

        accessMode=getAccessMode(port);
        portsSharingSameElem=filterValidSharedElems(portsSharingSameElem);
    end

    methods(Static,Access=public)
        function busPortValidator=getBusPortValidator(hModel)

            if autosar.api.Utils.isMappedToComponent(hModel)
                busPortValidator=autosar.validation.ClassicBusPortValidator();
            elseif autosar.api.Utils.isMappedToAdaptiveApplication(hModel)
                busPortValidator=autosar.validation.AdaptiveBusPortValidator();
            else
                assert(false,'Should not get here')
            end
        end
    end

    methods(Access=protected)
        function verifyCompositePortMappingBase(this)


            mapping=autosar.api.Utils.modelMapping(this.ModelH);

            inports=mapping.Inports;
            inportMap=this.captureAndValidatePortData(inports);
            this.verifyMapping(inportMap);


            outports=mapping.Outports;
            outportMap=this.captureAndValidatePortData(outports);
            this.verifyMapping(outportMap);

        end

        function portMap=captureAndValidatePortData(this,portMappings)

            portMap=containers.Map();
            for portIdx=1:numel(portMappings)
                port=portMappings(portIdx);

                slPortName=get_param(port.Block,'PortName');
                slElem=get_param(port.Block,'Element');
                accessMode=this.getAccessMode(port);

                if autosar.composition.Utils.isCompositePortBlock(port.Block)

                    this.validateShortName(slPortName,port.Block,...
                    'autosarstandard:validation:busPortInvalidPortName');
                    this.validateShortName(slElem,port.Block,...
                    'autosarstandard:validation:busPortInvalidElementName');
                end

                mappedPort=port.MappedTo.Port;
                mappedElem=port.MappedTo.(this.ElementPropName);
                if~isKey(portMap,mappedPort)
                    portMap(mappedPort)={};
                end

                data.block=port.Block;
                data.port=mappedPort;
                data.(this.ElementPropName)=mappedElem;
                data.(this.AccessModePropName)=accessMode;

                if isempty(data.port)&&isempty(data.(this.ElementPropName))
                    continue;
                end
                portMap(mappedPort)=[portMap(mappedPort),data];
            end
        end

        function verifyMapping(this,portMap)
            ports=portMap.keys;
            for portIdx=1:numel(ports)
                portName=ports{portIdx};
                portElems=portMap(portName);
                [~,uniqueIndexes,valueIndexes]=...
                unique(cellfun(@(x)x.(this.ElementPropName),portElems,"UniformOutput",false));
                for ii=1:numel(uniqueIndexes)
                    index=uniqueIndexes(ii);
                    portsSharingSameElem=portElems(valueIndexes==index);
                    if numel(portsSharingSameElem)==1

                        continue;
                    end

                    portsSharingSameElem=this.filterValidSharedElems(portsSharingSameElem);

                    if length(portsSharingSameElem)<2

                        continue;
                    end

                    usrReadableRefStr1=DAStudio.message('RTW:autosar:simulinkPort',portsSharingSameElem{1}.block);
                    usrReadableRefStr2=DAStudio.message('RTW:autosar:simulinkPort',portsSharingSameElem{2}.block);

                    modelName=bdroot(portsSharingSameElem{1}.block);



                    m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
                    m3iObjWithPortName=autosar.mm.Model.findChildByName(m3iComp,portName);
                    m3iPort=m3iObjWithPortName(arrayfun(@(x)isa(x,'Simulink.metamodel.arplatform.port.Port'),m3iObjWithPortName));
                    if~isempty(m3iPort)
                        interfaceQName=autosar.api.Utils.getQualifiedName(m3iPort.Interface);
                    else

                        componentAdapter=autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(modelName);
                        interfaceQName=componentAdapter.getAutosarInterfaceName(portsSharingSameElem{1}.block);
                    end

                    arElemName=portsSharingSameElem{1}.(this.ElementPropName);


                    msg=DAStudio.message('RTW:autosar:duplicateApi',...
                    usrReadableRefStr2,usrReadableRefStr1,arElemName,interfaceQName,portName);
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
            end
        end

        function validateShortName(this,shortName,blk,errorCode)
            if isempty(shortName)
                return;
            end
            maxShortNameLength=get_param(this.ModelH,'AutosarMaxShortNameLength');
            [isValid,errmsg]=autosarcore.checkIdentifier(shortName,'shortname',maxShortNameLength);
            if~isValid
                blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(blk);
                autosar.validation.Validator.logError(errorCode,blockStr,blk,errmsg);
            end
        end
    end

    methods(Static,Access=private)
        function verifyMessageQueueConfiguration(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);

            inports=mapping.Inports;
            for portIdx=1:length(inports)
                portBlock=inports(portIdx).Block;
                isMessage=get_param(portBlock,'CompiledPortIsMessage');
                if~isMessage.Outport||...
                    ~autosar.composition.Utils.isCompositePortBlock(portBlock)

                    continue;
                end

                isUsingDefault=...
                strcmp(get_param(portBlock,'MessageQueueUseDefaultAttributes'),...
                'on');

                isUsingFifo=...
                strcmp(get_param(portBlock,'MessageQueueType'),'FIFO');

                isBlocking=...
                strcmp(get_param(portBlock,'MessageQueueOverwriting'),'off');
                if isUsingDefault||~isUsingFifo||~isBlocking
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:unsupportedQueueConfig',...
                    portBlock);
                end
            end
        end
    end
end


