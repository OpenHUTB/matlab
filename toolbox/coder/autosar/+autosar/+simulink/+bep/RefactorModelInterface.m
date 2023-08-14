classdef RefactorModelInterface





    methods(Static)
        function[canRefactor,msgID,message]=canRefactorModelInterface(modelName)



            import autosar.simulink.bep.RefactorModelInterface


            msgID='';
            message='';



            containsVariants=RefactorModelInterface.containsVariantBlocks(modelName);
            canRefactor=~containsVariants||(slfeature('RootBEPVariantSupport')>0&&slfeature('AUTOSARBepVariant')>0);
            if~canRefactor
                msgID='autosarstandard:editor:BepConversionVariant';
                message=DAStudio.message(msgID);

                return;
            end
        end

        function[canRefactor,msgID,message]=canRefactorModelInterfaceBeforeLinking(modelName)





            import autosar.simulink.bep.RefactorModelInterface


            msgID='';
            message='';
            canRefactor=true;



            mapping=autosar.api.Utils.modelMapping(modelName);
            blockMappings=RefactorModelInterface.getSortedPortMappings(mapping);
            for i=1:length(blockMappings)
                blockMapping=blockMappings(i);
                [canRefactorPort,perPortMsgID,perPortMsg]=RefactorModelInterface.canConvertSignalToBEPs(modelName,blockMapping);

                if~canRefactorPort
                    msgID=perPortMsgID;
                    message=perPortMsg;
                    canRefactor=canRefactorPort;
                end
            end
        end

        function convertToBEPs(modelName,backupModel,issueWarnings)
            import autosar.simulink.bep.RefactorModelInterface

            assert(ischar(modelName),'Expected modelName to be a string');

            cleanupObj=autosar.simulink.bep.Mapping.BEPCallbackToggle.disableCallbacks();%#ok<NASGU>

            if nargin<2
                backupModel=false;
            end
            if nargin<3
                issueWarnings=true;
            end



            assert(Simulink.CodeMapping.isMappedToAutosarComponent(modelName)||...
            Simulink.CodeMapping.isMappedToAdaptiveApplication(modelName),...
            'model %s is not mapped to AUTOSAR component',modelName);


            RefactorModelInterface.errorOutIfNotConvertible(modelName);

            if backupModel
                autosar.utils.SimulinkModelCloner.backupModel(modelName,true);
            end


            mapping=autosar.api.Utils.modelMapping(modelName);
            blockMappings=RefactorModelInterface.getSortedPortMappings(mapping);


            for i=1:length(blockMappings)
                blockMapping=blockMappings(i);


                canConvertPort=RefactorModelInterface.canConvertSignalToBEPs(modelName,blockMapping,issueWarnings);
                if~canConvertPort
                    continue;
                end

                RefactorModelInterface.convertPortUsingBlockMapping(modelName,blockMapping)
            end

        end

        function convertPortUsingBlockMapping(modelName,blockMapping)




            import autosar.simulink.bep.RefactorModelInterface;
            busElementPort=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(modelName);



            cachedPortInfo=busElementPort.cachePortInfo(blockMapping);

            if busElementPort.isQoSPort(blockMapping)

                return;
            end

            if strcmp(get_param(blockMapping.Block,'IsComposite'),'on')

                return;
            end


            blks=find_system(modelName,'SearchDepth',1,'Name',blockMapping.MappedTo.Port);
            if~isempty(blks)

                blks=blks(~strcmp(blks,blockMapping.Block));
            end
            if~isempty(blks)

                blockBeingConverted=blockMapping.Block;
                blockPreventingConversion=getfullname(blks{1});
                MSLDiagnostic('autosarstandard:editor:BepConversionNameInUse',blockBeingConverted,blockPreventingConversion).reportAsWarning;
                return;
            end


            bep=RefactorModelInterface.convertPortBlockToBEP(...
            blockMapping.Block,blockMapping.MappedTo.Port,...
            busElementPort.getMappedElementName(blockMapping.MappedTo));


            busElementPort.restoreCachedPortInfo(bep,cachedPortInfo);
        end

        function convertMappedBusPortsToSignalPorts(modelName,backupModel,convertMessagePortsOnly)
            import autosar.simulink.bep.RefactorModelInterface



            assert(autosar.api.Utils.isMappedToComponent(modelName)||...
            autosar.api.Utils.isMappedToAdaptiveApplication(modelName),...
            'model %s is not mapped to AUTOSAR component',modelName);

            if backupModel
                autosar.utils.SimulinkModelCloner.backupModel(modelName,true);
            end


            mapping=autosar.api.Utils.modelMapping(modelName);
            blockMappings=[mapping.Inports,mapping.Outports];

            busElementPort=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(modelName);
            for i=1:length(blockMappings)
                blockMapping=blockMappings(i);

                if~autosar.composition.Utils.isCompositePortBlock(blockMapping.Block)

                    continue;
                end

                if convertMessagePortsOnly&&~busElementPort.isMessagePort(blockMapping)

                    continue;
                end



                cachedPortInfo=busElementPort.cachePortInfo(blockMapping);


                blk=RefactorModelInterface.convertBEPToPortBlock(...
                blockMapping.Block,blockMapping.MappedTo.Port,...
                busElementPort.getMappedElementName(blockMapping.MappedTo));


                busElementPort.restoreCachedPortInfo(blk,cachedPortInfo);

                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(blk);
            end

        end

        function exportToPreviousConverter(converterObj,messagePortsOnly)






            if nargin==1
                messagePortsOnly=false;
            end


            assert(Simulink.CodeMapping.isMappedToAutosarComponent(converterObj.modelName)||...
            Simulink.CodeMapping.isMappedToAdaptiveApplication(converterObj.modelName),...
            'Export to previous is only supported for component models')

            if Simulink.CodeMapping.isMappedToAutosarSubComponent(converterObj.modelName)

                return;
            end



            autosar.simulink.bep.Mapping.syncDictionary(converterObj.modelName);


            autosar.simulink.bep.RefactorModelInterface.convertMappedBusPortsToSignalPorts(converterObj.modelName,false,messagePortsOnly);
        end

        function exportToPreviousConverterForMessages(converterObj)



            messagePortsOnly=true;
            autosar.simulink.bep.RefactorModelInterface.exportToPreviousConverter(...
            converterObj,messagePortsOnly);
        end

        function[canConvertPorts,msgID,msg]=canConvertSignalToBEPs(modelName,blockMapping,issueWarnings)

            import autosar.simulink.bep.RefactorModelInterface

            if nargin<3
                issueWarnings=false;
            end


            msg='';
            msgID='';




            [hasMixedMessageSignalPorts,portsUsingMixedMessageSignal]=...
            autosar.validation.ClassicBusPortValidator.containsMixedMessageSignalPorts(modelName);



            [hasPortsWithNVBuses,portsWithNVBuses]=...
            RefactorModelInterface.hasPortsTypedWithNonVirtualBuses(modelName);



            [hasDuplicatePorts,duplicatePorts]=...
            RefactorModelInterface.containsDuplicatePorts(modelName);


            containsVariants=RefactorModelInterface.containsVariantBlocks(modelName);
            canConvertPorts=~containsVariants||...
            (slfeature('RootBEPVariantSupport')>0&&slfeature('AUTOSARBepVariant')>0);
            if~canConvertPorts
                msgID='autosarstandard:editor:BepConversionVariant';
                msg=DAStudio.message(msgID);

                return;
            end

            if(slfeature('CompositePortsNonvirtualBusSupport')<1||slfeature('AUTOSARBepNvBus')<1)...
                &&hasPortsWithNVBuses&&any(strcmp(blockMapping.Block,portsWithNVBuses))


                canConvertPorts=false;
                msgID='autosarstandard:editor:BepConversionNonVirtualBus';
                if issueWarnings==true
                    MSLDiagnostic(msgID,getfullname(blockMapping.Block)).reportAsWarning;
                else
                    msg=DAStudio.message(msgID,getfullname(blockMapping.Block));
                end
                return;
            end

            if hasDuplicatePorts&&any(strcmp(blockMapping.Block,duplicatePorts))

                canConvertPorts=false;
                msgID='autosarstandard:editor:BepConversionDuplicatePort';
                if issueWarnings==true
                    MSLDiagnostic(msgID,getfullname(blockMapping.Block)).reportAsWarning;
                else
                    msg=DAStudio.message(msgID,getfullname(blockMapping.Block));
                end
                return;
            end

            if hasMixedMessageSignalPorts&&any(strcmp(blockMapping.Block,...
                portsUsingMixedMessageSignal))


                canConvertPorts=false;
                msgID='autosarstandard:editor:BepConversionMixedMessageSignalPorts';
                if issueWarnings==true
                    MSLDiagnostic(msgID,getfullname(blockMapping.Block)).reportAsWarning;
                else
                    msg=DAStudio.message(msgID,getfullname(blockMapping.Block));
                end
                return;
            end

            if RefactorModelInterface.isSLPortMappingUsingPRPort(blockMapping)



                canConvertPorts=false;
                msgID='autosarstandard:editor:BepConversionPRPorts';
                if issueWarnings==true
                    MSLDiagnostic(msgID,getfullname(blockMapping.Block)).reportAsWarning;
                else
                    msg=DAStudio.message(msgID,getfullname(blockMapping.Block));
                end
                return;
            end
        end
    end

    methods(Static,Access=private)

        function errorOutIfNotConvertible(modelName)


            mapping=autosar.api.Utils.modelMapping(modelName);
            mapping.validateIO();

        end

        function[ret,ports]=hasPortsTypedWithNonVirtualBuses(modelName)



            mapping=autosar.api.Utils.modelMapping(modelName);


            portPaths={mapping.Inports.Block,mapping.Outports.Block};

            outputNonVirtualBus=strcmp(get_param(portPaths,'BusOutputAsStruct'),'on');
            outputsBusType=startsWith(get_param(portPaths,'OutDataTypeStr'),'Bus: ');
            ports=portPaths(outputNonVirtualBus&outputsBusType);
            ret=~isempty(ports);
        end

        function ret=containsVariantBlocks(modelName)



            variantSources=Simulink.findBlocksOfType(modelName,'VariantSource');
            variantSinks=Simulink.findBlocksOfType(modelName,'VariantSink');

            ret=~isempty(variantSources)||~isempty(variantSinks);
        end

        function[containsDuplicatePorts,portPaths]=containsDuplicatePorts(modelName)



            containsDuplicatePorts=false;
            portPaths={};

            shadowInports=find_system(modelName,'SearchDepth','1',...
            'BlockType','InportShadow');


            portNames=get_param(shadowInports,'PortName');

            for portIdx=1:length(shadowInports)
                dupedPorts=find_system(modelName,'SearchDepth','1',...
                'BlockType','Inport','PortName',portNames{portIdx});
                if~isempty(dupedPorts)
                    containsDuplicatePorts=true;
                    portPaths{end+1}=dupedPorts{1};%#ok<AGROW>
                end
            end
            portPaths=unique(portPaths);
        end

        function tf=isSLPortMappingUsingPRPort(slPortBlockMapping)
            mappedToARPort=slPortBlockMapping.MappedTo.Port;
            mapping=autosar.api.Utils.modelMapping(bdroot(slPortBlockMapping.Block));



            mappedInports=[mapping.Inports.MappedTo];
            mappedOutports=[mapping.Outports.MappedTo];
            tf=~isempty(mappedInports)&&~isempty(mappedOutports)&&...
            ismember(mappedToARPort,{mappedInports.Port})&&...
            ismember(mappedToARPort,{mappedOutports.Port});
        end

        function bep=convertPortBlockToBEP(blockPath,portName,elementName)
            import autosar.simulink.bep.Utils
            import autosar.simulink.bep.BlockReplaceUtils

            modelName=bdroot(blockPath);


            blkData=BlockReplaceUtils.getBlkDataAndDeleteLines(blockPath);
            portNumber=get_param(blockPath,'Port');
            isInport=strcmp(get_param(blockPath,'BlockType'),'Inport');


            delete_block(blockPath);

            bep=Utils.addBusElement(modelName,portName,elementName,isInport,portNumber);

            bep=getfullname(bep);
            BlockReplaceUtils.restoreBlockData(bep,blkData);
        end

        function blk=convertBEPToPortBlock(blockPath,portName,elementName)
            import autosar.simulink.bep.Utils
            import autosar.simulink.bep.BlockReplaceUtils

            modelName=bdroot(blockPath);


            blkData=BlockReplaceUtils.getBlkDataAndDeleteLines(blockPath);
            portNumber=get_param(blockPath,'Port');
            isInport=strcmp(get_param(blockPath,'BlockType'),'Inport');


            delete_block(blockPath);

            blk=Utils.addPortBlock(modelName,portName,elementName,isInport,portNumber);

            blk=getfullname(blk);
            BlockReplaceUtils.restoreBlockData(blk,blkData);
        end

        function portMappings=getSortedPortMappings(mapping)



            inports=mapping.Inports;
            outports=mapping.Outports;

            inportMappedTo=[inports.MappedTo];
            outportMappedTo=[outports.MappedTo];

            inputPorts=arrayfun(@(x)x.Port,inportMappedTo,'UniformOutput',false);
            outputPorts=arrayfun(@(x)x.Port,outportMappedTo,'UniformOutput',false);





            [~,inputIdx]=sort(inputPorts);
            [~,outputIdx]=sort(outputPorts);

            portMappings=[inports(inputIdx),outports(outputIdx)];
        end
    end
end


