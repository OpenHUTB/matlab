classdef DictionarySyncer





    methods(Static,Access=public)

        function sync(model)


            if autosar.api.Utils.isMappedToAdaptiveApplication(model)



                clientPorts=...
                autosar.simulink.functionPorts.Utils.findClientPorts(...
                model);
                for clientPortIdx=1:length(clientPorts)
                    autosar.simulink.functionPorts.DictionarySyncer.syncClientPort(...
                    model,clientPorts{clientPortIdx});
                end

                serverPorts=...
                autosar.simulink.functionPorts.Utils.findServerPorts(...
                model);
                for serverPortIdx=1:length(serverPorts)
                    autosar.simulink.functionPorts.DictionarySyncer.syncServerPort(...
                    model,serverPorts{serverPortIdx});
                end

                if~isempty(clientPorts)||~isempty(serverPorts)


                    autosar.simulink.functionPorts.DictionarySyncer.deleteUnusedPorts(model);
                end
            end
        end
    end

    methods(Static,Access=private)
        function syncClientPort(modelH,fcnPortPath)
            portType='client';
            autosar.simulink.functionPorts.DictionarySyncer.syncFunctionPort(...
            modelH,fcnPortPath,portType);
        end

        function syncServerPort(modelH,fcnPortPath)
            portType='server';
            autosar.simulink.functionPorts.DictionarySyncer.syncFunctionPort(...
            modelH,fcnPortPath,portType);
        end

        function syncFunctionPort(modelH,fcnPortPath,portType)

            m3iComp=autosar.api.Utils.m3iMappedComponent(modelH);
            switch portType
            case 'client'
                portClass='Simulink.metamodel.arplatform.port.ServiceRequiredPort';
                portSeq=m3iComp.RequiredPorts;
                isCaller=true;
            case 'server'
                portClass='Simulink.metamodel.arplatform.port.ServiceProvidedPort';
                portSeq=m3iComp.ProvidedPorts;
                isCaller=false;
            otherwise
                assert(false,'Unexpected port type')
            end

            portName=get_param(fcnPortPath,'PortName');
            fcnName=[portName,'.',get_param(fcnPortPath,'Element')];

            implBlockH=...
            autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(modelH,fcnName,isCaller);
            if isempty(implBlockH)




                return;
            end

            m3iModelLocal=autosarcore.ModelUtils.getLocalElementsM3IModel(modelH);
            localTrans=autosar.utils.M3ITransaction(m3iModelLocal);

            m3iPort=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iComp,portSeq,portName,portClass);

            m3iModelShared=autosarcore.ModelUtils.getSharedElementsM3IModel(modelH);
            sharedTrans=autosar.utils.M3ITransaction(m3iModelShared);

            componentAdapter=autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(modelH);
            interfaceName=componentAdapter.getAutosarInterfaceName(fcnPortPath);

            m3iInterface=m3iPort.Interface;
            if~m3iInterface.isvalid()


                m3iInterfaceMetaClass=...
                Simulink.metamodel.arplatform.interface.ServiceInterface.MetaClass;
                m3iRootPackage=m3iModelShared.rootModel.RootPackage.at(1);
                m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
                m3iRootPackage,...
                interfaceName,...
                m3iInterfaceMetaClass);

                if m3iSeq.size>0
                    m3iInterface=m3iSeq.at(1);
                else

                    m3iIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,...
                    m3iRootPackage.InterfacePackage);
                    interfaceClass='Simulink.metamodel.arplatform.interface.ServiceInterface';
                    m3iInterface=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iIfPkg,m3iIfPkg.packagedElement,interfaceName,interfaceClass);
                end

                m3iPort.Interface=m3iInterface;
            end

            methodName=componentAdapter.getAutosarMethodName(fcnName);
            methodClass='Simulink.metamodel.arplatform.interface.Operation';
            m3iMethod=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.Methods,...
            methodName,methodClass);

            autosar.simulink.functionPorts.DictionarySyncer.setM3IArgumentsFromBlock(modelH,fcnName,m3iMethod,fcnPortPath);

            if slfeature('AUTOSARMethodsFireAndForgetMapping')
                autosar.simulink.functionPorts.DictionarySyncer.setFireAndForget(m3iMethod,fcnPortPath,portType);
            else
                autosar.simulink.functionPorts.DictionarySyncer.inferFireAndForget(m3iMethod);
            end

            localTrans.commit();
            sharedTrans.commit();
        end

        function setM3IArgumentsFromBlock(modelH,fcnName,m3iMethod,fcnPortPath)





            fcnName=autosar.simulink.functionPorts.Utils.escapeBrackets(fcnName);
            autosar.ui.utils.addArguments(modelH,fcnName,m3iMethod);

            [inArgs,outArgs]=autosar.simulink.functionPorts.Utils.getArgumentsFromFunctionPort(modelH,fcnPortPath);
            argumentNames=[inArgs,outArgs];



            m3iArgsToDestroy=m3i.filter(@(m3iArg)~ismember(m3iArg.Name,argumentNames),m3iMethod.Arguments);
            for argIdx=1:length(m3iArgsToDestroy)
                m3iArgsToDestroy{argIdx}.destroy();
            end
        end

        function inferFireAndForget(m3iMethod)





            argDirections=...
            m3i.mapcell(@(m3iArg)m3iArg.Direction.toString(),m3iMethod.Arguments);
            m3iMethod.FireAndForget=isempty(argDirections)||...
            all(cellfun(@(argDirection)...
            strcmp(argDirection,Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In.toString),...
            argDirections));
        end

        function setFireAndForget(m3iMethod,fcnPortPath,portType)


            mapping=autosar.api.Utils.modelMapping(bdroot(fcnPortPath));

            switch portType
            case 'client'
                blockMappingVec=mapping.ClientPorts;
            case 'server'
                blockMappingVec=mapping.ServerPorts;
            otherwise
                assert(false,'Unexpected port type');
            end

            blockMapping=blockMappingVec.findobj('Block',fcnPortPath);
            if strcmp(blockMapping.MappedTo.FireAndForget,'true')
                m3iMethod.FireAndForget=true;
            else
                m3iMethod.FireAndForget=false;
            end
        end

        function deleteUnusedPorts(modelH)




            m3iModelLocal=autosarcore.ModelUtils.getLocalElementsM3IModel(modelH);
            localTrans=autosar.utils.M3ITransaction(m3iModelLocal);

            autosar.simulink.functionPorts.DictionarySyncer.deleteUnusedClientPorts(modelH);
            autosar.simulink.functionPorts.DictionarySyncer.deleteUnusedServerPorts(modelH);

            localTrans.commit();
        end

        function deleteUnusedClientPorts(modelH)
            mappingCat='Inports';
            componentCat='RequiredPorts';
            blockPaths=...
            autosar.simulink.functionPorts.Utils.findClientPorts(modelH);
            portClass='Simulink.metamodel.arplatform.port.ServiceRequiredPort';
            autosar.simulink.functionPorts.DictionarySyncer.findAndDeleteUnusedPorts(...
            modelH,mappingCat,componentCat,blockPaths,portClass);
        end

        function deleteUnusedServerPorts(modelH)
            mappingCat='Outports';
            componentCat='ProvidedPorts';
            blockPaths=...
            autosar.simulink.functionPorts.Utils.findServerPorts(modelH);
            portClass='Simulink.metamodel.arplatform.port.ServiceProvidedPort';
            autosar.simulink.functionPorts.DictionarySyncer.findAndDeleteUnusedPorts(...
            modelH,mappingCat,componentCat,blockPaths,portClass);
        end

        function findAndDeleteUnusedPorts(modelH,mappingCat,componentCat,blockPaths,portClass)
            mapping=autosar.api.Utils.modelMapping(modelH);
            usedPorts=arrayfun(@(x)x.MappedTo.Port,mapping.(mappingCat),'UniformOutput',false);

            if~isempty(blockPaths)
                usedPorts=[usedPorts,get_param(blockPaths,'PortName')'];
            end

            usedPorts=unique(usedPorts);
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelH);
            allArPorts=m3i.mapcell(@(x)x.Name,m3iComp.(componentCat));
            portsToDelete=setdiff(allArPorts,usedPorts);

            for elemIdx=1:numel(portsToDelete)
                port=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.(componentCat),...
                portsToDelete{elemIdx},portClass);
                port.destroy();
            end
        end
    end
end


