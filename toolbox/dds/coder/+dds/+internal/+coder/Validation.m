classdef Validation





    properties
    end

    methods(Static)
        function preCompileValidate(modelName)



            if~dds.internal.isInstalledAndLicensed()
                return;
            end

            ME=MSLException(message('dds:cgen:DDSCodegenValidationFailed'));


            reg=dds.internal.vendor.DDSRegistry;
            vendors=reg.getVendorList;
            allowedToolchains=cell(1,numel(vendors));
            for i=1:numel(vendors)
                entry=reg.getEntryFor(vendors(i).Key);
                allowedToolchains{i}=entry.DefaultToolchain;
            end
            curToolchain=get_param(modelName,'Toolchain');
            if~ismember(curToolchain,allowedToolchains)
                warning(message('dds:cgen:NonDDSToolchainUsed'));
            end


            if~strcmp(get_param(modelName,'TargetLangStandard'),'C++11 (ISO)')
                ME=ME.addCause(MSLException(message('dds:cgen:Cpp11StandardMathLibraryRequired',...
                get_param(modelName,'TargetLangStandard'),modelName)));
            end


            if~strcmp(get_param(modelName,'CodeInterfacePackaging'),'C++ class')
                ME=ME.addCause(MSLException(message('dds:cgen:InvalidCodeInterfacePackaging',...
                get_param(modelName,'CodeInterfacePackaging'),modelName)));
            end


            [attached,~,~]=dds.internal.simulink.Util.isModelAttachedToDDSDictionary(modelName);
            if~attached
                ME=ME.addCause(MSLException(message('dds:cgen:NoDDSDictionaryAttached',...
                modelName)));
            end


            if~strcmp(get_param(modelName,'MatFileLogging'),'off')
                ME=ME.addCause(MSLException(message('dds:cgen:MatFileLoggingNotSupport',...
                modelName)));
            end


            if~strcmp(get_param(modelName,'ExtMode'),'off')
                ME=ME.addCause(MSLException(message('dds:cgen:ExtModeNotSupport',...
                modelName)));
            end


            mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
            if isempty(mapping.Inports)&&isempty(mapping.Outports)
                ME=ME.addCause(MSLException(message('dds:cgen:ModelHasNoIOPort',...
                modelName)));
            end


            if dds.internal.coder.Validation.usesInputEvents(mapping)&&...
                ~dds.internal.coder.Validation.isInputEventToolchain(curToolchain)
                ME=ME.addCause(MSLException(message('dds:cgen:VendorNotSupportedForInputEvents',...
                curToolchain,modelName)));
            end


            if~isempty(dds.internal.coder.Validation.findAllMessageTriggeredSubsystems(modelName))
                ME=ME.addCause(MSLException(message('dds:cgen:MsgTriggeredSubSysNotSupport',...
                modelName)));
            end


            if strcmp(get_param(modelName,'ConcurrentTasks'),'off')&&...
                strcmp(get_param(modelName,'EnableMultiTasking'),'on')
                ME=ME.addCause(MSLException(message('dds:cgen:ConcurrentTasksDisabled',...
                modelName)));
            end

            if~isempty(ME.cause)
                ME.throwAsCaller;
            end
        end

        function PostCompileValidate(modelName)

            reader2InportsMap=containers.Map('KeyType','char','ValueType','any');
            writer2OutportsMap=containers.Map('KeyType','char','ValueType','any');

            mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
            dictName=get_param(modelName,'DataDictionary');
            dictObj=Simulink.data.dictionary.open(dictName);
            sectionObj=dictObj.getSection('Design Data');

            ME=MSLException(message('dds:cgen:DDSCodegenValidationFailed'));


            if~isempty(mapping.FcnCallInports)
                for fcnCallInports=mapping.FcnCallInports
                    ME=ME.addCause(MSLException(message('dds:cgen:NonMessageIOPort',...
                    'Inport',modelName,fcnCallInports.Block)));
                end
            end



            aperiodicPartitions=dds.internal.coder.Validation.findAllAperiodicPartitions(modelName);
            if~dds.internal.coder.Validation.quereyAllAperiodicPartitionsTriggered(aperiodicPartitions)
                nAperiodicPartitions=size(aperiodicPartitions,1);
                for i=1:nAperiodicPartitions
                    if aperiodicPartitions(i,3).Trigger.strlength==0
                        partitionName=aperiodicPartitions.Partition{i,:};
                        ME=ME.addCause(MSLException(message('dds:cgen:UntriggeredAperiodicPartition',...
                        partitionName,modelName)));
                        break;
                    end
                end
            end

            for inport=mapping.Inports
                isInport=true;


                ME=dds.internal.coder.Validation.validateIsMsgPort(...
                modelName,inport,isInport,ME);


                ME=dds.internal.coder.Validation.validatePortDataTypeExistInDDSDict(...
                modelName,inport,isInport,ME);


                ME=dds.internal.coder.Validation.validateMappingObjectsExistInDDSDict(...
                modelName,inport,isInport,ME);


                ME=dds.internal.coder.Validation.validateTopicAndPortDataTypeMatch(...
                modelName,inport,isInport,ME);


                ME=dds.internal.coder.Validation...
                .validateDataTypeContainNDArray(inport,isInport,sectionObj,ME);


                reader2InportsMap=dds.internal.coder.Validation.addReaderWriterToPortMap(...
                inport,reader2InportsMap);
            end

            for outport=mapping.Outports
                isInport=false;


                ME=dds.internal.coder.Validation.validateIsMsgPort(...
                modelName,outport,isInport,ME);


                ME=dds.internal.coder.Validation.validatePortDataTypeExistInDDSDict(...
                modelName,outport,isInport,ME);


                ME=dds.internal.coder.Validation.validateMappingObjectsExistInDDSDict(...
                modelName,outport,isInport,ME);


                ME=dds.internal.coder.Validation.validateTopicAndPortDataTypeMatch(...
                modelName,outport,isInport,ME);


                ME=dds.internal.coder.Validation...
                .validateDataTypeContainNDArray(outport,isInport,sectionObj,ME);


                writer2OutportsMap=dds.internal.coder.Validation.addReaderWriterToPortMap(...
                outport,writer2OutportsMap);
            end


            ME=dds.internal.coder.Validation.validateMultipleIOMapsToSameReaderWriter(...
            'Inports','DataReader',reader2InportsMap,modelName,ME);
            ME=dds.internal.coder.Validation.validateMultipleIOMapsToSameReaderWriter(...
            'Outports','DataWriter',writer2OutportsMap,modelName,ME);


            [~,~,vendorKey,~]=dds.internal.simulink.Util.getCurrentMapSetting(modelName);
            reg=dds.internal.vendor.DDSRegistry;
            entry=reg.getEntryFor(vendorKey);
            ME=entry.VendorPostCompileValidation(modelName,ME);

            if~isempty(ME.cause)
                ME.throw;
            end
        end

        function ME=validateIsMsgPort(modelName,...
            portMapping,isInport,ME)

            blockPath=portMapping.Block;
            if isInport
                InOutStr='Inport';
                isMsg=get_param(blockPath,'CompiledPortIsMessage').Outport;
            else
                InOutStr='Outport';
                isMsg=get_param(blockPath,'CompiledPortIsMessage').Inport;
            end
            if~isMsg
                ME=ME.addCause(MSLException(message('dds:cgen:NonMessageIOPort',...
                InOutStr,modelName,blockPath)));
            end
        end

        function ME=validatePortDataTypeExistInDDSDict(modelName,...
            portMapping,isInport,ME)

            blockPath=portMapping.Block;
            if isInport
                type=get_param(blockPath,'CompiledPortDataTypes').Outport{1};
                InOutStr='Inport';
            else
                type=get_param(blockPath,'CompiledPortDataTypes').Inport{1};
                InOutStr='Outport';
            end
            ddsType=dds.internal.simulink.Util.getDDSType(modelName,type);
            if isempty(ddsType)
                ME=ME.addCause(MSLException(message('dds:cgen:TypeNotExistedInDictionary',...
                InOutStr,blockPath,type)));
            end
        end

        function ME=validateMappingObjectsExistInDDSDict(modelName,...
            portMapping,isInport,ME)

            blockPath=portMapping.Block;
            if isInport
                InOutStr='Inport';
            else
                InOutStr='Outport';
            end


            topicPath=portMapping.MessageCustomization.Topic;
            if isempty(topicPath)
                ME=ME.addCause(MSLException(message('dds:cgen:TopicNotMapped',...
                InOutStr,blockPath)));
            else
                topic=dds.internal.simulink.Util.getTopic(modelName,topicPath);
                if isempty(topic)
                    ME=ME.addCause(MSLException(message('dds:cgen:TopicDoesNotExistInDictionary',...
                    InOutStr,blockPath,topicPath)));
                end
            end


            qosPath=portMapping.MessageCustomization.ReaderWriterQOS;
            if~isempty(qosPath)
                qos=dds.internal.simulink.Util.getQoS(modelName,qosPath,isInport);
                if isempty(qos)
                    ME=ME.addCause(MSLException(message('dds:cgen:QoSDoesNotExistInDictionary',...
                    InOutStr,blockPath,qosPath)));
                end
            end


            readerWriterPath=portMapping.MessageCustomization.ReaderWriterPath;
            if isempty(readerWriterPath)
                if isInport
                    ME=ME.addCause(MSLException(message('dds:cgen:DataReaderNotMapped',...
                    blockPath)));
                else
                    ME=ME.addCause(MSLException(message('dds:cgen:DataWriterNotMapped',...
                    blockPath)));
                end
            else
                if isInport
                    readerWriter=dds.internal.simulink.getDataReader(modelName,readerWriterPath);
                else
                    readerWriter=dds.internal.simulink.getDataWriter(modelName,readerWriterPath);
                end
                if isempty(readerWriter)
                    if isInport
                        ME=ME.addCause(MSLException(message('dds:cgen:DataReaderDoesNotExistInDictionary',...
                        blockPath,readerWriterPath)));
                    else
                        ME=ME.addCause(MSLException(message('dds:cgen:DataWriterDoesNotExistInDictionary',...
                        blockPath,readerWriterPath)));
                    end
                end
            end
        end

        function ME=validateTopicAndPortDataTypeMatch(modelName,...
            portMapping,isInport,ME)

            blockPath=portMapping.Block;
            if isInport
                portType=get_param(blockPath,'CompiledPortDataTypes').Outport{1};
                InOutStr='Inport';
            else
                portType=get_param(blockPath,'CompiledPortDataTypes').Inport{1};
                InOutStr='Outport';
            end

            topicPath=portMapping.MessageCustomization.Topic;
            topic=dds.internal.simulink.Util.getTopic(modelName,topicPath);

            if~isempty(topic)
                topicType=topic.RegisterTypeRef.TypeRef;
                ddsPortType=dds.internal.simulink.Util.getDDSType(modelName,portType);
                if isempty(ddsPortType)||ddsPortType~=topicType
                    ME=ME.addCause(MSLException(message('dds:cgen:PortAndTopicTypeInconsistency',...
                    InOutStr,blockPath,portType,topicPath,topicType.Name)));
                end
            end
        end


        function map=addReaderWriterToPortMap(portMapping,map)
            readerWriterPath=portMapping.MessageCustomization.ReaderWriterPath;
            if isempty(readerWriterPath)
                return;
            end
            if map.isKey(readerWriterPath)
                inports=map(readerWriterPath);
                inports{end+1}=portMapping.Block;
                map(readerWriterPath)=inports;
            else
                map(readerWriterPath)={portMapping.Block};
            end
        end

        function ME=validateMultipleIOMapsToSameReaderWriter(...
            InOutStr,readerWriterStr,readerWriter2PortMap,modelName,ME)
            readerWriters=keys(readerWriter2PortMap);
            for i=1:numel(readerWriters)
                readerWriter=readerWriters{i};
                ports=readerWriter2PortMap(readerWriter);
                if(length(ports)>1)
                    portsStr='';
                    for j=1:numel(ports)
                        port=ports{j};
                        portsStr=[portsStr,port];
                        if j<numel(ports)
                            portsStr=[portsStr,' and '];
                        end
                    end
                    ME=ME.addCause(MSLException(message('dds:cgen:MultiplePortsMapsToSameReaderWriter',...
                    InOutStr,readerWriterStr,modelName,portsStr,readerWriter)));
                end
            end
        end

        function ME=validateDataTypeContainNDArray(portMapping,isInport,sectionObj,ME)
            blockPath=portMapping.Block;
            if isInport
                type=get_param(blockPath,'CompiledPortDataTypes').Outport{1};
                InOutStr='Inport';
            else
                type=get_param(blockPath,'CompiledPortDataTypes').Inport{1};
                InOutStr='Outport';
            end
            if dds.internal.coder.Validation...
                .doesBusTypeContainNDArray(type,sectionObj)
                ME=ME.addCause(MSLException(message('dds:cgen:DDSNotSupportNDArray',...
                InOutStr,blockPath,type)));
            end
        end

        function res=doesBusTypeContainNDArray(typeName,sectionObj)
            res=false;
            if~sectionObj.exist(typeName)



                return;
            end
            type=sectionObj.getEntry(typeName).getValue;
            busElements=type.Elements;
            for i=1:numel(busElements)
                elem=busElements(i);
                dim=elem.Dimensions;
                if length(dim)>1
                    res=true;
                elseif strcmpi(elem.DataType,'Bus: ')
                    typeName=elem.DataType(6:end);
                    res=dds.internal.coder.Validation.doesBusTypeContainND(typeName);
                end
                if res
                    return;
                end
            end
        end

        function isSupported=isInputEventToolchain(toolchain)
            isSupported=strcmp(toolchain,'RTI Connext 6.0 Project');
        end

        function modelHasDataEvents=usesInputEvents(mapping)
            modelHasDataEvents=false;
            for port=mapping.Inports
                block=port.Block;
                if~isempty(get_param(block,'EventTriggers'))
                    modelHasDataEvents=true;
                end
            end
        end

        function msgTriggeredSampleTimeSSBlks=findAllMessageTriggeredSubsystems(hModel)
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                ssBlocks=find_system(hModel,'MatchFilter',@Simulink.match.activeVariants,...
                'Type','block','BlockType','SubSystem');
            else
                ssBlocks=find_system(hModel,'Type','block','BlockType','SubSystem');
            end

            msgTriggeredSampleTimeSSBlks=ssBlocks(...
            arrayfun(@(x)dds.internal.coder.Validation.isAnyKindOfMessageTriggeredSS(x),...
            ssBlocks));
        end

        function isAnyKindOfMessageTriggeredSS=isAnyKindOfMessageTriggeredSS(sys)
            isAnyKindOfMessageTriggeredSS=false;
            if strcmp(get_param(sys,'BlockType'),'SubSystem')
                ssType=Simulink.SubsystemType(sys{1});
                isAnyKindOfMessageTriggeredSS=ssType.isMessageTriggeredSampleTime()||...
                ssType.isMessageTriggeredFunction();
            end
        end





        function allAperiodicPartitionsTriggered=quereyAllAperiodicPartitionsTriggered(aperiodicPartitions)
            allAperiodicPartitionsTriggered=true;
            triggers=aperiodicPartitions.Trigger;
            nPartitions=length(triggers);
            for i=1:nPartitions
                if triggers(i).strlength==0
                    allAperiodicPartitionsTriggered=false;
                    break;
                end
            end
        end





        function aperiodicPartitions=findAllAperiodicPartitions(model)
            schedule=get_param(model,'schedule');
            aperiodicIndexes=schedule.Order.Type==simulink.schedule.PartitionType.Aperiodic;
            aperiodicPartitions=schedule.Order(aperiodicIndexes,:);
        end
    end
end



