classdef CommonModelingStylesValidator<autosar.validation.PhasedValidator






    methods(Access=protected)

        function verifyInitial(self,hModel)
            self.checkRootNodeIsVirtual(hModel);
            self.checkBusPortValidElement(hModel);
            self.checkNoBepVirtualBusElements(hModel);
            self.checkModeBepPortsHaveOneElement(hModel);
            self.checkBusPortSharedInterfaces(hModel);
            self.checkBusPortNameCaseInsensitive(hModel);
        end

        function verifyPostProp(self,hModel)
            self.checkVirtualBusDrivingBusPort(hModel);
        end
    end

    methods(Static)



        function checkRootNodeIsVirtual(hModel)
            if slfeature('CompositePortsNonvirtualBusSupport')<1
                return;
            end

            modelName=get_param(hModel,'Name');
            busElementPortsAtRoot=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(modelName);
            for ii=1:numel(busElementPortsAtRoot)
                blk=busElementPortsAtRoot(ii);
                if strcmp(autosar.simulink.bep.Utils.getParam(blk,true,'Virtuality'),'nonvirtual')
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:BusPortRootNonVirtual',...
                    getfullname(blk));
                end
            end
        end



        function checkBusPortValidElement(hModel)
            modelName=get_param(hModel,'Name');
            busElementPortsAtRoot=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(modelName);
            for ii=1:numel(busElementPortsAtRoot)
                blk=busElementPortsAtRoot(ii);
                blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(blk);
                if autosar.validation.CommonModelingStylesValidator.busElementIsInvalid(blk)
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:BusPortNotMappedToDataElement',...
                    blockStr,getfullname(blk));
                end
            end
        end



        function checkNoBepVirtualBusElements(hModel)
            modelName=get_param(hModel,'Name');
            busElementPortsAtRoot=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(modelName);
            for ii=1:numel(busElementPortsAtRoot)
                blk=busElementPortsAtRoot(ii);
                if autosar.validation.CommonModelingStylesValidator.busElementIsInvalid(blk)

                    continue;
                end
                bepDataType=autosar.simulink.bep.Utils.getParam(blk,false,'OutDataTypeStr');
                if startsWith(bepDataType,'Bus:')
                    if slfeature('CompositePortsNonvirtualBusSupport')>0...
                        &&slfeature('AUTOSARBepNvBus')>0
                        if~strcmp(autosar.simulink.bep.Utils.getParam(blk,false,'Virtuality'),'nonvirtual')
                            blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(blk);
                            autosar.validation.Validator.logError(...
                            'autosarstandard:validation:BusElementPortUsingVirtualBusTypeOnElement',...
                            blockStr,getfullname(blk));
                        end
                    else
                        blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(blk);
                        autosar.validation.Validator.logError(...
                        'autosarstandard:validation:BusElementPortUsingBusTypeOnElement',...
                        blockStr,getfullname(blk));
                    end
                end
            end
        end



        function checkModeBepPortsHaveOneElement(hModel)

            modelName=get_param(hModel,'Name');

            busElementPortsAtRoot=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(modelName);
            for ii=1:numel(busElementPortsAtRoot)
                blk=busElementPortsAtRoot(ii);

                if autosar.simulink.bep.Utils.isBepModePort(modelName,blk)

                    elements=autosar.simulink.bep.Utils.getElements(blk);
                    if numel(elements)>1
                        blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(blk);
                        [usingBus,busObjName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(blk);
                        if usingBus
                            autosar.validation.Validator.logError(...
                            'autosarstandard:validation:modeBusPortHasMultipleElementsBus',...
                            blockStr,getfullname(blk),busObjName);
                        else
                            autosar.validation.Validator.logError(...
                            'autosarstandard:validation:modeBusPortHasMultipleElements',...
                            blockStr,getfullname(blk))
                        end
                    end
                end
            end
        end





        function checkVirtualBusDrivingBusPort(hModel)
            modelName=get_param(hModel,'Name');
            busElementPortsAtRoot=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(modelName);
            for ii=1:numel(busElementPortsAtRoot)
                blk=busElementPortsAtRoot(ii);
                if~strcmp(get_param(blk,'BlockType'),'Outport')

                    continue;
                end
                lines=get_param(blk,'LineHandles');
                inportLines=[lines.Inport];
                if isempty(inportLines)||inportLines==-1 %#ok<BDSCI>
                    return;
                end
                lineObj=get_param(inportLines,'Object');
                srcPort=lineObj.getSourcePort();
                if~isempty(srcPort)&&strcmp(srcPort.CompiledBusType,'VIRTUAL_BUS')
                    blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(blk);
                    autosar.validation.Validator.logErrorAndFlush(...
                    'autosarstandard:validation:busPortDrivenByVirtualBus',...
                    blockStr,getfullname(blk));
                end
            end
        end




        function checkBusPortSharedInterfaces(hModel)

            function checkInterfaceSeq(interfaceSeq,m3iInterfaceToPortSeqMap)
                for ii=1:interfaceSeq.size()
                    busPortsSharingInterface={};

                    m3iInterface=interfaceSeq.at(ii);
                    if~m3iInterfaceToPortSeqMap.isKey(m3iInterface.Name)

                        continue;
                    end
                    portSeq=m3iInterfaceToPortSeqMap(m3iInterface.Name);

                    for jj=1:portSeq.size()
                        m3iPort=portSeq.at(jj);
                        if~contains(autosar.api.Utils.getQualifiedName(m3iPort),m3iCompQualPath)

                            continue;
                        end

                        m3iPortName=m3iPort.Name;


                        matchingBusPorts=strcmp(m3iPortName,allBusPortBlocks_PortName);


                        matchingBusPortBlock=allBusPortBlocks(matchingBusPorts);
                        if~isempty(matchingBusPortBlock)
                            busPortsSharingInterface=[busPortsSharingInterface;matchingBusPortBlock{1}];%#ok<AGROW>
                        end
                    end


                    if numel(busPortsSharingInterface)>1
                        [isUsingBusDefinition,busObjName]=cellfun(...
                        @(x)autosar.simulink.bep.Utils.isBEPUsingBusObject(x),...
                        busPortsSharingInterface,'UniformOutput',false);

                        if any([isUsingBusDefinition{:}])&&~all(strcmp(busObjName,busObjName{1}))

                            autosar.validation.Validator.logError(...
                            'autosarstandard:validation:busPortsSharedInterfaceSeparateBus',...
                            autosar.api.Utils.cell2str(busPortsSharingInterface));
                        end
                    end
                end
            end

            modelName=get_param(hModel,'Name');
            mapping=autosar.api.Utils.modelMapping(modelName);


            allPorts=[mapping.Inports,mapping.Outports];
            allPortBlocks={allPorts.Block};
            allBusPortBlocks=allPortBlocks(cellfun(@(x)autosar.composition.Utils.isCompositePortBlock(x),allPortBlocks));
            allBusPortBlocks_PortName=cellfun(@(x)get_param(x,'PortName'),allBusPortBlocks,'UniformOutput',false);

            m3iModel=autosar.api.Utils.m3iModel(modelName);
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iCompQualPath=autosar.api.Utils.getQualifiedName(m3iComp);

            m3iInterfaceToPortSeqMap=autosar.mm.Model.captureInterfaceToPortSeqMap(m3iModel,m3iComp);


            srInterfaces=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.interface.SenderReceiverInterface.MetaClass);
            nvInterfaces=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.interface.NvDataInterface.MetaClass);
            msInterfaces=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.interface.ModeSwitchInterface.MetaClass);

            checkInterfaceSeq(srInterfaces,m3iInterfaceToPortSeqMap);
            checkInterfaceSeq(nvInterfaces,m3iInterfaceToPortSeqMap);
            checkInterfaceSeq(msInterfaces,m3iInterfaceToPortSeqMap);
        end

        function isInvalid=busElementIsInvalid(blk)
            isInvalid=autosar.simulink.bep.Utils.isRootPort(blk)...
            ||contains(get_param(blk,'Element'),'.');
        end

        function checkBusPortNameCaseInsensitive(hModel)


            modelName=get_param(hModel,'Name');
            busElementPortsAtRoot=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(modelName);
            if isempty(busElementPortsAtRoot)
                return;
            end

            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            ports=autosar.mm.Model.findObjectByMetaClass(m3iComp,Simulink.metamodel.arplatform.port.Port.MetaClass,true,true);

            numBEPs=numel(busElementPortsAtRoot);
            numArPorts=ports.size();
            totalLength=numBEPs+numArPorts;
            portNames=cell(1,totalLength);

            if numBEPs==1
                portNames{1}=get_param(busElementPortsAtRoot,'PortName');
            else
                portNames(1:numBEPs)=get_param(busElementPortsAtRoot,'PortName');
            end

            for ii=1:numArPorts
                portNames{numBEPs+ii}=ports.at(ii).Name;
            end

            autosar.validation.AutosarUtils.checkShortNameCaseClash(portNames);
        end
    end
end



