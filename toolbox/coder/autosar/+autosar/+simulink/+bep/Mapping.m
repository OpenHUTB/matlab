classdef Mapping





    properties(Constant)
        BEPCallbackToggle autosar.simulink.bep.CallbackToggle=autosar.simulink.bep.CallbackToggle();
    end

    methods(Static,Access=public)
        function portAdded(blkH)


            if~autosar.simulink.bep.Mapping.BEPCallbackToggle.areCallbacksEnabled()
                return;
            end

            if autosar.simulink.functionPorts.Utils.isClientServerPort(blkH)
                return;
            end

            busElementPort=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(bdroot(blkH));

            createDefault=true;

            portName=get_param(blkH,'PortName');
            busPortMappings=autosar.simulink.bep.Mapping.getPortMappingsForBlk(blkH,portName,'');
            if~isempty(busPortMappings)
                bepMapping=busElementPort.getMatchingMappingforBlk(blkH,busPortMappings);
                if~isempty(bepMapping)
                    createDefault=false;
                end
            end

            if createDefault

                busElementPort.createDefaultMapping(blkH);
            else


                busElementPort.applyMapping(blkH,bepMapping);
            end
        end

        function portNameChanged(blkH,newPortName,oldPortName)


            if~autosar.simulink.bep.Mapping.BEPCallbackToggle.areCallbacksEnabled()
                return;
            end

            busElementPort=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(bdroot(blkH));

            if autosar.simulink.bep.Utils.isRootPort(blkH)
                busElementPort.createDefaultMapping(blkH);
                return;
            end

            if~autosar.simulink.bep.Mapping.portHasValidMapping(blkH)
                return;
            end

            portMappings=autosar.simulink.bep.Mapping.getPortMappingsForBlk(blkH,oldPortName,'');

            busElementPort.updateMappingForPortNameChange(blkH,portMappings,newPortName);
        end

        function dataElementNameChanged(blkH,newElementName,oldElementName)


            if~autosar.simulink.bep.Mapping.BEPCallbackToggle.areCallbacksEnabled()
                return;
            end


            busElementPort=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(bdroot(blkH));
            if autosar.simulink.bep.Utils.isRootPort(blkH)
                busElementPort.createDefaultMapping(blkH);
                return;
            end

            [isValid,port]=autosar.simulink.bep.Mapping.portHasValidMapping(blkH);
            if~isValid
                return;
            end

            portName=get_param(port.Block,'PortName');
            portMappings=autosar.simulink.bep.Mapping.getPortMappingsForBlk(blkH,portName,oldElementName);

            busElementPort.updateMappingForElementNameChange(port,portMappings,newElementName);
        end

        function blockCheckParamChange(blkH,paramName,newValue)



            if~autosar.simulink.bep.Mapping.BEPCallbackToggle.areCallbacksEnabled()
                return;
            end

            assert(autosar.composition.Utils.isCompositePortBlock(blkH),'Expected Bus Port block');

            switch paramName
            case{'PortName','Element'}
                if isempty(newValue)
                    return;
                end

                if~(autosar.simulink.bep.Mapping.portHasValidMapping(blkH)||...
                    autosar.simulink.functionPorts.Utils.isClientServerPort(blkH))
                    return;
                end

                modelName=getfullname(bdroot(blkH));
                autosar.api.Utils.checkQualifiedName(modelName,newValue,'shortname');
            otherwise

            end
        end

        function syncDictionary(model)


            if autosar.api.Utils.isMappedToComponent(model)||...
                autosar.api.Utils.isMappedToAdaptiveApplication(model)

                mapping=autosar.api.Utils.modelMapping(model);
                slMappingApi=autosar.api.getSimulinkMapping(model);
                m3iComp=autosar.api.Utils.m3iMappedComponent(model);
                modelH=get_param(model,'Handle');

                componentBuilder=autosar.ui.wizard.builder.Component(model,model,...
                'PreserveExistingMapping',true);


                m3iModelLocal=autosarcore.ModelUtils.getLocalElementsM3IModel(model);
                transObj=autosar.utils.M3ITransaction(m3iModelLocal);

                m3iModelShared=autosarcore.ModelUtils.getSharedElementsM3IModel(model);
                componentBuilder.setDefaultConfiguration(modelH);
                componentBuilder.mapInportsAndOutports(...
                model,mapping,slMappingApi,m3iModelShared,m3iComp,false,'onlyBep');


                transObj.commit();
            end
        end

        function m3iPort=syncBusPort(blkPath)
            try

                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

                assert(autosar.composition.Utils.isCompositePortBlock(blkPath),'Expected bus port block');
                model=bdroot(blkPath);
                assert(autosar.api.Utils.isMappedToComponent(model),'Model is not mapped to an AUTOSAR Component');

                mapping=autosar.api.Utils.modelMapping(model);
                slMappingApi=autosar.api.getSimulinkMapping(model);
                m3iComp=autosar.api.Utils.m3iMappedComponent(model);
                isAdaptive=Simulink.CodeMapping.isMappedToAdaptiveApplication(model);
                isInport=strcmp(get_param(blkPath,'BlockType'),'Inport');

                if isInport
                    [portName,elementName,dataAccessMode]=slMappingApi.getInport(get_param(blkPath,'Name'));
                else
                    [portName,elementName,dataAccessMode]=slMappingApi.getOutport(get_param(blkPath,'Name'));
                end

                componentBuilder=autosar.ui.wizard.builder.Component(model,model,...
                'PreserveExistingMapping',true);


                m3iModelLocal=autosarcore.ModelUtils.getLocalElementsM3IModel(model);
                transObj=autosar.utils.M3ITransaction(m3iModelLocal);

                m3iModelShared=autosarcore.ModelUtils.getSharedElementsM3IModel(model);
                m3iPort=componentBuilder.mapSlPort(blkPath,model,mapping,slMappingApi,m3iModelShared,m3iComp,isAdaptive);
                if~isAdaptive
                    autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec(portName,elementName,dataAccessMode,model);
                end


                transObj.commit();

            catch Me

                autosar.mm.util.MessageReporter.throwException(Me);
            end
        end

        function[isValid,port]=portHasValidDataPortMapping(blkH)
            if autosar.composition.Utils.isCompositionModel(bdroot(blkH))
                isValid=true;
                port=[];
                return;
            end

            modelName=bdroot(blkH);
            blockPath=getfullname(blkH);
            mapping=autosar.api.Utils.modelMapping(modelName);


            isInport=strcmp(get_param(blkH,'BlockType'),'Inport');
            if isInport
                port=mapping.Inports.findobj('Block',blockPath);
            else
                port=mapping.Outports.findobj('Block',blockPath);
            end

            isValid=~isempty(port);
        end

        function[isValid,port]=portHasValidMapping(blkH)
            if autosar.composition.Utils.isCompositionModel(bdroot(blkH))
                isValid=true;
                port=[];
                return;
            end


            blockMappings=autosar.simulink.bep.Mapping.getBlockMappingsForBlockType(blkH);
            blockPath=getfullname(blkH);
            port=blockMappings.findobj('Block',blockPath);
            isValid=~isempty(port);
        end
    end

    methods(Static,Access=private)
        function portMappings=getPortMappingsForBlk(blkH,portName,elementName)

            narginchk(3,3);

            modelName=bdroot(blkH);

            portMappings=autosar.simulink.bep.Mapping.getBlockMappingsForBlockType(blkH);

            bepTemplate=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(modelName);
            if isempty(elementName)

                portMappings=portMappings(cellfun(@(x)strcmp(x.Port,portName),{portMappings.MappedTo}));
            else

                portMappings=portMappings(...
                cellfun(@(x)strcmp(x.Port,portName)&&...
                strcmp(bepTemplate.getMappedElementName(x),elementName),...
                {portMappings.MappedTo}));

                bepBeingChanged=arrayfun(@(x)strcmp(x.Block,getfullname(blkH)),portMappings);
                qosPorts=arrayfun(@(x)bepTemplate.isQoSPort(x),portMappings);

                if sum(~qosPorts)>1


                    portMappings=portMappings(bepBeingChanged);
                else


                    portMappings=portMappings(bepBeingChanged|qosPorts);
                end
            end

        end

        function blockMappings=getBlockMappingsForBlockType(blkH)

            isInport=strcmp(get_param(blkH,'BlockType'),'Inport');
            modelName=bdroot(blkH);
            mapping=autosar.api.Utils.modelMapping(modelName);

            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)&&...
                autosar.simulink.functionPorts.Utils.isClientServerPort(blkH)
                if isInport
                    blockMappings=mapping.ClientPorts;
                else
                    blockMappings=mapping.ServerPorts;
                end
            else
                if isInport
                    blockMappings=mapping.Inports;
                else
                    blockMappings=mapping.Outports;
                end
            end
        end
    end
end


