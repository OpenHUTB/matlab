classdef Migrator<handle
















    properties
ROSModelName
ROSBusList
ROSMessages
ROSMessageList
ROSPubSubBlocks
ROSTopicsAndType
ROSQoS
    end

    properties
DDSModelName
DDSDictionaryName
DDSVendor
DDSAdaptiveFwd
    end

    properties
SystemName
UseCoreMessageBlock
CreateFwd
    end

    properties(Hidden)
DDSDictConn
    end

    methods
        function h=Migrator(varargin)
            h.parseInputs(varargin{:});

            load_system(h.ROSModelName);

            feval(h.ROSModelName,[],[],[],'compile');
            feval(h.ROSModelName,[],[],[],'term');


            h.analyzeROSModel();
            h.createDDSDictionary();
            h.createDDSModel();


            feval(h.DDSModelName,[],[],[],'compile');
            feval(h.DDSModelName,[],[],[],'term');
            if h.CreateFwd
                feval(h.DDSAdaptiveFwd,[],[],[],'compile');
                feval(h.DDSAdaptiveFwd,[],[],[],'term');
            end
            save_system(h.DDSModelName);
            if h.CreateFwd
                save_system(h.DDSAdaptiveFwd);
            end
            h.DDSDictConn.saveChanges;
            h.DDSDictConn=[];
        end




        function analyzeROSModel(h)

            function addMsgBasedOnBusGraph(busName,parent)
                busName=strrep(busName,'Bus: ','');
                rosSimObj=ros.slros2.internal.bus.Util.getBusObjectFromBusName(busName,'');
                rosMsgType=h.getROSMessageFromSimObj(rosSimObj);
                if~isempty(parent)
                    h.addToGraph('ROSMessages',parent,rosMsgType);
                else
                    h.addToGraph('ROSMessages',rosMsgType,'');
                end
                for j=1:numel(rosSimObj.Elements)
                    elemMsgType=h.getROSMessageFromSimObj(rosSimObj.Elements(j));
                    if~isempty(elemMsgType)
                        h.addToGraph('ROSMessages',rosMsgType,elemMsgType);
                        addMsgBasedOnBusGraph(rosSimObj.Elements(j).DataType,rosMsgType);
                    end
                end
            end


            h.ROSBusList=ros.ros2.createSimulinkBus(h.ROSModelName);
            h.ROSMessages=digraph();

            for i=1:numel(h.ROSBusList)
                addMsgBasedOnBusGraph(h.ROSBusList{i},'');
            end



            h.ROSMessageList=h.getSortedList('ROSMessages');


            h.ROSTopicsAndType=containers.Map;
            h.ROSQoS=containers.Map;
            h.ROSPubSubBlocks=...
            ros.slros.internal.bus.Util.listBlocks(h.ROSModelName,...
            ['('...
            ,ros.slros2.internal.block.PublishBlockMask.getMaskType,'|',...
            ros.slros2.internal.block.SubscribeBlockMask.getMaskType,...
            ')']);
            for i=1:numel(h.ROSPubSubBlocks)



                topic=get_param(h.ROSPubSubBlocks{i},'topic');
                entry.msgType=get_param(h.ROSPubSubBlocks{i},'messageType');
                entry.blocks={h.ROSPubSubBlocks{i}};%#ok<CCAT1> 
                if h.ROSTopicsAndType.isKey(topic)
                    curEnt=h.ROSTopicsAndType(topic);
                    entry.blocks=[curEnt.blocks,entry.blocks];
                end
                h.ROSTopicsAndType(topic)=entry;
                writer=isequal(get_param(h.ROSPubSubBlocks{i},'MaskType'),ros.slros2.internal.block.PublishBlockMask.getMaskType);
                h.ROSQoS(h.ROSPubSubBlocks{i})=struct(...
                'History',get_param(h.ROSPubSubBlocks{i},'QOSHistory'),...
                'Depth',get_param(h.ROSPubSubBlocks{i},'QOSDepth'),...
                'Reliability',get_param(h.ROSPubSubBlocks{i},'QOSReliability'),...
                'Durability',get_param(h.ROSPubSubBlocks{i},'QOSDurability'),...
                'Writer',writer);
            end
        end


        function createDDSDictionary(h)
            if~isfile(h.DDSDictionaryName)
                h.DDSDictConn=Simulink.data.dictionary.create(h.DDSDictionaryName);
            else
                h.DDSDictConn=Simulink.data.dictionary.open(h.DDSDictionaryName);
            end

            source=h.DDSDictConn.filepath;
            hasDDSpart=Simulink.DDSDictionary.ModelRegistry.hasDDSPart(source);
            if hasDDSpart
                ddsModel=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(source);
            else
                ddsModel=mf.zero.Model;

                sys=dds.datamodel.system.System(ddsModel);
                sys.Name=h.DDSModelName;
                Simulink.DDSDictionary.ModelRegistry.registerWithDD(ddsModel,source);
                dds.internal.simulink.Util.importFromDDSToSimulink(h.DDSDictConn);
            end


            txn=ddsModel.beginTransaction;
            sys=dds.internal.getSystemInModel(ddsModel);
            if isempty(sys)

                sys(1)=dds.datamodel.system.System(ddsModel);
            end


            if sys(1).TypeLibraries.Size<1


                typeLibNode=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,[],'dds.datamodel.types.TypeLibrary','');
                sys(1).TypeLibraries.add(typeLibNode);
            else
                typeLibNode=sys(1).TypeLibraries(1);
            end

            for i=1:numel(h.ROSMessageList)
                h.addROSMessage(ddsModel,sys,typeLibNode,h.ROSMessageList{i});
            end


            if sys(1).DomainLibraries.Size<1||isempty(sys(1).DomainLibraries{h.SystemName})
                domainLib=dds.datamodel.domain.DomainLibrary(ddsModel);
                domainLib.Name=h.SystemName;
                sys(1).DomainLibraries.add(domainLib);
            else
                domainLib=sys(1).DomainLibraries{h.SystemName};
            end

            if domainLib.Domains.Size<1||isempty(domainLib.Domains{h.getDDSDomain()})
                domain=dds.datamodel.domain.Domain(ddsModel);
                domain.Name=h.getDDSDomain;
                domainLib.Domains.add(domain);
            else
                domain=domainLib.Domains{h.getDDSDomain()};
            end

            topics=h.ROSTopicsAndType.keys;
            for i=1:numel(topics)
                h.addROSTopic(ddsModel,sys,domain,topics{i});
            end


            if sys(1).QosLibraries.Size<1||isempty(sys(1).QosLibraries{h.getQosLibName()})
                qosLib=dds.datamodel.qos.QosLibrary(ddsModel);
                qosLib.Name=h.getQosLibName();
                sys(1).QosLibraries.add(qosLib);
            else
                qosLib=sys(1).QosLibraries{h.getQosLibName()};
            end


            for i=1:numel(h.ROSPubSubBlocks)
                qosName=h.getQoSName(h.ROSPubSubBlocks{i},h.ROSModelName);
                qosFwdName=[qosName,'_FWD'];
                rosQos=h.ROSQoS(h.ROSPubSubBlocks{i});
                if rosQos.Writer
                    theQos=qosLib.DataWriterQoses{qosName};
                    if isempty(theQos)
                        theQos=dds.datamodel.qos.DataWriterQos(ddsModel);
                        theQos.Name=qosName;
                        qosLib.DataWriterQoses.add(theQos);
                    end
                    if h.CreateFwd
                        theQosFwd=qosLib.DataReaderQoses{qosFwdName};
                        if isempty(theQosFwd)
                            theQosFwd=dds.datamodel.qos.DataReaderQos(ddsModel);
                            theQosFwd.Name=qosFwdName;
                            qosLib.DataReaderQoses.add(theQosFwd);
                        end
                    end
                else
                    theQos=qosLib.DataReaderQoses{qosName};
                    if isempty(theQos)
                        theQos=dds.datamodel.qos.DataReaderQos(ddsModel);
                        theQos.Name=qosName;
                        qosLib.DataReaderQoses.add(theQos);
                    end
                    if h.CreateFwd
                        theQosFwd=qosLib.DataWriterQoses{qosFwdName};
                        if isempty(theQosFwd)
                            theQosFwd=dds.datamodel.qos.DataWriterQos(ddsModel);
                            theQosFwd.Name=qosFwdName;
                            qosLib.DataWriterQoses.add(theQosFwd);
                        end
                    end
                end


                if isempty(theQos.History)
                    theQos.History=dds.datamodel.qos.HistoryQosPolicy(ddsModel);
                    if h.CreateFwd
                        theQosFwd.History=dds.datamodel.qos.HistoryQosPolicy(ddsModel);
                    end
                    if contains(rosQos.History,'Keep last','IgnoreCase',true)
                        theQos.History.Kind=dds.datamodel.qos.ddstypes.HistoryKind.KEEP_LAST_HISTORY_QOS;
                        theQos.History.Depth=uint64(str2double(rosQos.Depth));
                        if h.CreateFwd
                            theQosFwd.History.Kind=dds.datamodel.qos.ddstypes.HistoryKind.KEEP_LAST_HISTORY_QOS;
                            theQosFwd.History.Depth=uint64(str2double(rosQos.Depth));
                        end
                    else
                        theQos.History.Kind=dds.datamodel.qos.ddstypes.HistoryKind.KEEP_ALL_HISTORY_QOS;
                        if h.CreateFwd
                            theQosFwd.History.Kind=dds.datamodel.qos.ddstypes.HistoryKind.KEEP_ALL_HISTORY_QOS;
                        end
                    end
                else
                    if contains(rosQos.History,'Keep last','IgnoreCase',true)
                        assert(isequal(theQos.History.Depth,uint64(str2double(rosQos.Depth))));
                    else
                        assert(isequal(theQos.History.Kind,dds.datamodel.qos.ddstypes.HistoryKind.KEEP_ALL_HISTORY_QOS));
                    end
                end

                if isempty(theQos.Reliability)
                    theQos.Reliability=dds.datamodel.qos.ReliabilityQosPolicy(ddsModel);
                    if h.CreateFwd
                        theQosFwd.Reliability=dds.datamodel.qos.ReliabilityQosPolicy(ddsModel);
                    end
                    if contains(rosQos.Reliability,'Best effort','IgnoreCase',true)
                        theQos.Reliability.Kind=dds.datamodel.qos.ddstypes.ReliabilityKind.BEST_EFFORT_RELIABILITY_QOS;
                        if h.CreateFwd
                            theQosFwd.Reliability.Kind=dds.datamodel.qos.ddstypes.ReliabilityKind.BEST_EFFORT_RELIABILITY_QOS;
                        end
                    else
                        theQos.Reliability.Kind=dds.datamodel.qos.ddstypes.ReliabilityKind.RELIABLE_RELIABILITY_QOS;
                        if h.CreateFwd
                            theQosFwd.Reliability.Kind=dds.datamodel.qos.ddstypes.ReliabilityKind.RELIABLE_RELIABILITY_QOS;
                        end
                    end
                else
                    if contains(rosQos.Reliability,'Best effort','IgnoreCase',true)
                        assert(isequal(theQos.Reliability.Kind,dds.datamodel.qos.ddstypes.ReliabilityKind.BEST_EFFORT_RELIABILITY_QOS));
                    else
                        assert(isequal(theQos.Reliability.Kind,dds.datamodel.qos.ddstypes.ReliabilityKind.RELIABLE_RELIABILITY_QOS));
                    end
                end

                if isempty(theQos.Durability)
                    theQos.Durability=dds.datamodel.qos.DurabilityQosPolicy(ddsModel);
                    if h.CreateFwd
                        theQosFwd.Durability=dds.datamodel.qos.DurabilityQosPolicy(ddsModel);
                    end
                    if contains(rosQos.Durability,'Volatile','IgnoreCase',true)
                        theQos.Durability.Kind=dds.datamodel.qos.ddstypes.DurabilityKind.VOLATILE_DURABILITY_QOS;
                        if h.CreateFwd
                            theQosFwd.Durability.Kind=dds.datamodel.qos.ddstypes.DurabilityKind.VOLATILE_DURABILITY_QOS;
                        end
                    else
                        theQos.Durability.Kind=dds.datamodel.qos.ddstypes.DurabilityKind.TRANSIENT_LOCAL_DURABILITY_QOS;
                        if h.CreateFwd
                            theQosFwd.Durability.Kind=dds.datamodel.qos.ddstypes.DurabilityKind.TRANSIENT_LOCAL_DURABILITY_QOS;
                        end
                    end
                else
                    if contains(rosQos.Durability,'Volatile','IgnoreCase',true)
                        assert(isequal(theQos.Durability.Kind,dds.datamodel.qos.ddstypes.DurabilityKind.VOLATILE_DURABILITY_QOS));
                    else
                        assert(isequal(theQos.Durability.Kind,dds.datamodel.qos.ddstypes.DurabilityKind.TRANSIENT_LOCAL_DURABILITY_QOS));
                    end
                end
            end

            txn.commit;


            h.DDSDictConn.saveChanges;
        end


        function createDDSModel(h)


            function connect(blockParentPath,srcBlkHdl,dstBlkHdl,srcBlkPort,dstBlkPort)
                if nargin<5
                    dstBlkPort='1';
                end
                if nargin<4
                    srcBlkPort='1';
                end
                add_line(blockParentPath,...
                [get_param(srcBlkHdl,'Name'),'/',srcBlkPort],...
                [get_param(dstBlkHdl,'Name'),'/',dstBlkPort],...
                'autorouting','smart');
            end






            function[lineHdl,srcBlkHdl,srcBlkPort,srcBlkPortHdl]=getLineSrc(portHdl)
                lineHdl=get_param(portHdl,'Line');
                srcBlkHdl=get_param(lineHdl,'SrcBlockHandle');
                srcBlkPortHdl=get_param(lineHdl,'SrcPortHandle');
                srcBlkPort=num2str(get_param(srcBlkPortHdl,'PortNumber'));
            end






            function[lineHdl,dstBlkHdl,dstBlkPort,dstBlkPortHdl]=getLineEnd(portHdl)
                lineHdl=get_param(portHdl,'Line');
                dstBlkHdl=get_param(lineHdl,'DstBlockHandle');
                dstBlkPortHdl=get_param(lineHdl,'DstPortHandle');
                dstBlkPortType=get_param(dstBlkPortHdl,'PortType');
                if contains(dstBlkPortType,'enable',"IgnoreCase",true)
                    dstBlkPort='Enable';
                else
                    dstBlkPort=num2str(get_param(dstBlkPortHdl,'PortNumber'));
                end
            end




            function setBusType(bepBlkHdl,typeStr)
                pb=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(bepBlkHdl);




                node=pb.port.tree;
                Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(node,typeStr);
                Simulink.internal.CompositePorts.TreeNode.setVirtualityCL(node,sl.mfzero.treeNode.Virtuality.NON_VIRTUAL);
            end










            function topPortHdl=routePortToTop(innerPortHdl)
                parent=get_param(innerPortHdl,'Parent');
                if~isequal(parent,h.DDSModelName)
                    grandParent=fileparts(parent);
                    innerPortName=get_param(innerPortHdl,'Name');
                    portName=[grandParent,'/',innerPortName];
                    innerPortNumOnParent=get_param(innerPortHdl,'Port');
                    parentPortHandles=get_param(parent,'PortHandles');
                    innerType=get_param(innerPortHdl,'BlockType');
                    if isequal(innerType,'Outport')
                        portParentPos=get_param(parentPortHandles.Outport(str2double(innerPortNumOnParent)),'Position');
                        portPos=[portParentPos(1)+70,portParentPos(2)-10,portParentPos(1)+100,portParentPos(2)+10];
                        newPortHdl=add_block('built-in/Outport',portName,'MakeNameUnique','on','Position',portPos);
                        connect(grandParent,get_param(parent,'Handle'),newPortHdl,innerPortNumOnParent);
                    else
                        portParentPos=get_param(parentPortHandles.Inport(str2double(innerPortNumOnParent)),'Position');
                        portPos=[portParentPos(1)-100,portParentPos(2)-10,portParentPos(1)-70,portParentPos(2)+10];
                        newPortHdl=add_block('built-in/Inport',portName,'MakeNameUnique','on','Position',portPos);
                        connect(grandParent,newPortHdl,get_param(parent,'Handle'),'1',innerPortNumOnParent);
                    end
                    set_param(newPortHdl,'OutDataTypeStr',get_param(innerPortHdl,'OutDataTypeStr'));
                    set_param(newPortHdl,'BusOutputAsStruct','On');
                    topPortHdl=routePortToTop(newPortHdl);
                else
                    topPortHdl=innerPortHdl;
                end

            end









            function replacePubBlock(blockPath,mapping)
                [blockParentPath,blockName]=fileparts(blockPath);
                rosBlkHdl=get_param(blockPath,'Handle');
                rosBlkPos=get_param(rosBlkHdl,'Position');
                rosPortHdls=get_param(rosBlkHdl,'PortHandles');
                rosInPort=rosPortHdls.Inport;
                [inputLineHdl,upstreamBlk]=getLineSrc(rosInPort);
                rosMsgType=get_param(rosBlkHdl,'messageType');
                rosTopic=get_param(rosBlkHdl,'topic');
                ddsTopic=h.getDDSTopic(rosTopic);
                ddsTopicAsPortName=strrep(ddsTopic,'/','_');


                delete_block(rosBlkHdl);
                delete_line(inputLineHdl);


                newBlkPos=[rosBlkPos(1)-20,rosBlkPos(2),rosBlkPos(3)-70,rosBlkPos(4)];
                newBlkName=[blockParentPath,'/',blockName,'write'];
                if h.UseCoreMessageBlock
                    newBlkHdl=add_block('built-in/Send',...
                    newBlkName,'MakeNameUnique','on',...
                    'Position',newBlkPos);
                else
                    newBlkHdl=add_block('ddsblock/Write DDS Sample',...
                    newBlkName,'MakeNameUnique','on',...
                    'Position',newBlkPos);
                end
                connect(blockParentPath,upstreamBlk,newBlkHdl);

                newBlkPorts=get_param(newBlkHdl,'PortHandles');
                newBlkOutPortPos=get_param(newBlkPorts.Outport,'Position');
                portPos=[newBlkOutPortPos(1)+35,newBlkOutPortPos(2)-10,newBlkOutPortPos(1)+65,newBlkOutPortPos(2)+10];
                portName=[blockParentPath,'/',ddsTopicAsPortName];
                outportHdl=add_block('built-in/Outport',portName,'MakeNameUnique','on','Position',portPos);
                connect(blockParentPath,newBlkHdl,outportHdl);
                [~,~,~,~,ddsTypeSimObjName,~,~]=...
                h.getDDSAndROSNames(rosMsgType);
                lddsType=['Bus: ',ddsTypeSimObjName];
                set_param(outportHdl,'OutDataTypeStr',lddsType);
                set_param(outportHdl,'BusOutputAsStruct','On');


                topPortHdl=routePortToTop(outportHdl);
                topPortIdx=str2double(get_param(topPortHdl,'Port'));
                mapping.sync;
                mapping.Outports(topPortIdx).MessageCustomization.ConfigurationMode='Use Topic and QoS';
                mapping.Outports(topPortIdx).MessageCustomization.Topic=[h.SystemName,'/',h.getDDSDomain(),'/',ddsTopic];
                qosName=h.getQoSName(blockPath,h.DDSModelName);
                mapping.Outports(topPortIdx).MessageCustomization.ReaderWriterQOS=[h.getQosLibName(),'/',qosName];
            end









            function replaceSubBlock(blockPath,mapping)
                [blockParentPath,blockName]=fileparts(blockPath);
                rosBlkHdl=get_param(blockPath,'Handle');
                rosBlkPos=get_param(rosBlkHdl,'Position');
                rosPortHdls=get_param(rosBlkHdl,'PortHandles');
                rosOutPorts=rosPortHdls.Outport;
                statusPortUsed=numel(rosOutPorts)>1;
                rosMsgType=get_param(rosBlkHdl,'messageType');
                rosTopic=get_param(rosBlkHdl,'topic');
                ddsTopic=h.getDDSTopic(rosTopic);
                ddsTopicAsPortName=strrep(ddsTopic,'/','_');
                rosSampleTime=get_param(rosBlkHdl,'sampleTime');

                if statusPortUsed
                    [statusLineHdl,statusLineDstBlk,statusLineDstPortName]=getLineEnd(rosOutPorts(1));
                    [outputLineHdl,outputLineDstBlk,outputLineDstPortName]=getLineEnd(rosOutPorts(2));
                else
                    statusLineHdl=[];
                    [outputLineHdl,outputLineDstBlk,outputLineDstPortName]=getLineEnd(rosOutPorts(1));
                end


                delete_block(rosBlkHdl);
                if statusPortUsed
                    delete_line(statusLineHdl);
                end
                delete_line(outputLineHdl);


                newBlkPos=[rosBlkPos(1)+70,rosBlkPos(2),rosBlkPos(3)+5,rosBlkPos(4)];
                newBlkName=[blockParentPath,'/',blockName,'read'];
                if h.UseCoreMessageBlock
                    newBlkHdl=add_block('built-in/Receive',...
                    newBlkName,'MakeNameUnique','on',...
                    'Position',newBlkPos);
                    set_param(newBlkHdl,'UseInternalQueue','off');
                    set_param(newBlkHdl,'ValueSourceWhenQueueIsEmpty','Hold last value');
                else
                    newBlkHdl=add_block('ddsblock/Take DDS Sample',...
                    newBlkName,'MakeNameUnique','on',...
                    'Position',newBlkPos);
                end
                if statusPortUsed
                    set_param(newBlkHdl,'ShowQueueStatus','on');
                    connect(blockParentPath,newBlkHdl,statusLineDstBlk,'1',statusLineDstPortName);
                    connect(blockParentPath,newBlkHdl,outputLineDstBlk,'2',outputLineDstPortName);
                else
                    connect(blockParentPath,newBlkHdl,outputLineDstBlk,'1',outputLineDstPortName);
                end

                newBlkPorts=get_param(newBlkHdl,'PortHandles');
                newBlkOutPortPos=get_param(newBlkPorts.Inport,'Position');
                portPos=[newBlkOutPortPos(1)-65,newBlkOutPortPos(2)-10,newBlkOutPortPos(1)-35,newBlkOutPortPos(2)+10];
                portName=[blockParentPath,'/',ddsTopicAsPortName];
                inportHdl=add_block('built-in/Inport',portName,'MakeNameUnique','on','Position',portPos);
                connect(blockParentPath,inportHdl,newBlkHdl);
                [~,~,~,~,ddsTypeSimObjName,~,~]=...
                h.getDDSAndROSNames(rosMsgType);
                lddsType=['Bus: ',ddsTypeSimObjName];
                set_param(inportHdl,'OutDataTypeStr',lddsType);
                set_param(inportHdl,'BusOutputAsStruct','On');
                set_param(inportHdl,'SampleTime',rosSampleTime);


                topPortHdl=routePortToTop(inportHdl);
                topPortIdx=str2double(get_param(topPortHdl,'Port'));
                mapping.sync;
                mapping.Inports(topPortIdx).MessageCustomization.ConfigurationMode='Use Topic and QoS';
                mapping.Inports(topPortIdx).MessageCustomization.Topic=[h.SystemName,'/',h.getDDSDomain(),'/',ddsTopic];
                qosName=h.getQoSName(blockPath,h.DDSModelName);
                mapping.Inports(topPortIdx).MessageCustomization.ReaderWriterQOS=[h.getQosLibName(),'/',qosName];
            end





            function replaceMsgBlock(blockPath)
                blockParentPath=fileparts(blockPath);
                rosBlkHdl=get_param(blockPath,'Handle');
                rosPortHdls=get_param(rosBlkHdl,'PortHandles');
                rosOutPort=rosPortHdls.Outport;
                try
                    rosMsgType=get_param(rosBlkHdl,'entityType');
                catch ME %#ok<NASGU> 
                    rosMsgType=get_param(rosBlkHdl,'messageType');
                end
                [lineToBusSelectorHdl,busAssignHdl]=getLineEnd(rosOutPort);
                [~,~,~,~,ddsTypeSimObjName,~,~]=...
                h.getDDSAndROSNames(rosMsgType);
                lddsType=['Bus: ',ddsTypeSimObjName];

                busAssignType=get_param(busAssignHdl,'BlockType');
                if~isequal(busAssignType,'BusAssignment')
                    warning(['Not able to handle: ',blockPath]);
                    set_param(rosBlkHdl,'Commented','on');
                    return;
                end

                assignedSignals=strsplit(get_param(busAssignHdl,'AssignedSignals'),',');
                inputMap=struct('lineHdl',cell(1,numel(assignedSignals)),...
                'srcBlkHdl',cell(1,numel(assignedSignals)),...
                'srcBlkPort',cell(1,numel(assignedSignals)));
                assignPortHdls=get_param(busAssignHdl,'PortHandles');
                for inIdx=1:numel(assignedSignals)
                    [inputMap(inIdx).lineHdl,inputMap(inIdx).srcBlkHdl,inputMap(inIdx).srcBlkPort]=...
                    getLineSrc(assignPortHdls.Inport(inIdx+1));
                end
                [outputLineHdl,outputLineDstBlk,outputLineDstPortName]=getLineEnd(assignPortHdls.Outport(1));
                assignBlkPos=get_param(busAssignHdl,'Position');
                assignBlkName=get_param(busAssignHdl,'Name');



                delete_block(rosBlkHdl);
                delete_line(lineToBusSelectorHdl);
                delete_block(busAssignHdl);
                delete_line(outputLineHdl);
                for inIdx=1:numel(assignedSignals)
                    delete_line(inputMap(inIdx).lineHdl);
                end


                newBlkName=[blockParentPath,'/',assignBlkName];
                subsysHdl=add_block('built-in/Subsystem',newBlkName,'MakeNameUnique','on','Position',assignBlkPos);
                nextYpos=10;
                canUseBEP=h.getCanUseBEP(ddsTypeSimObjName);
                for inIdx=1:numel(assignedSignals)
                    baseName=[newBlkName,'/',assignedSignals{inIdx}];
                    isSLInfo=h.getIsSLInfo(assignedSignals{inIdx});
                    inPortPos=[10,nextYpos,50,nextYpos+50];
                    outPortPos=[100,nextYpos,150,nextYpos+50];

                    inPortHdl=add_block('built-in/Inport',[baseName,'_in'],'MakeNameUnique','on','Position',inPortPos);
                    if isSLInfo
                        outPortHdl=add_block('simulink/Sinks/Terminator',[baseName,'_out'],'MakeNameUnique','on','Position',outPortPos);
                        connect(newBlkName,inPortHdl,outPortHdl);
                    else
                        if canUseBEP
                            outPortHdl=add_block('simulink/Sinks/Out Bus Element',[baseName,'_out'],'MakeNameUnique','on','Position',outPortPos);
                            set_param(outPortHdl,'Element',assignedSignals{inIdx});
                            setBusType(outPortHdl,lddsType);
                            connect(newBlkName,inPortHdl,outPortHdl);
                        else

                            newBusGenPos=[10,nextYpos-100,50,nextYpos-50];
                            newBusGen=[newBlkName,'/',assignedSignals{inIdx},'_busgen'];
                            subsysHdlBusGen=add_block('built-in/Subsystem',newBusGen,'MakeNameUnique','on','Position',newBusGenPos);
                            inBusGenHdl=add_block('simulink/Sources/Ground',[newBusGen,'/gnd'],'MakeNameUnique','on','Position',inPortPos);
                            outBusGenHdl=add_block('built-in/Outport',[newBusGen,'/out'],'MakeNameUnique','on','Position',outPortPos);
                            set_param(outBusGenHdl,'OutDataTypeStr',lddsType);
                            connect(newBusGen,inBusGenHdl,outBusGenHdl);
                            busAssignHdl=add_block('simulink/Signal Routing/Bus Assignment',[baseName,'_assign'],'MakeNameUnique','on','Position',outPortPos);
                            set_param(busAssignHdl,'AssignedSignals',assignedSignals{inIdx});
                            outPortPos2=[100+100,nextYpos,150+100,nextYpos+50];

                            outPortHdl2=add_block('simulink/Sinks/Out1',[baseName,'_assign'],'MakeNameUnique','on','Position',outPortPos2);
                            set_param(outPortHdl2,'OutDataTypeStr',lddsType);
                            connect(newBlkName,subsysHdlBusGen,busAssignHdl,'1','1');
                            connect(newBlkName,inPortHdl,busAssignHdl,'1','2');
                            connect(newBlkName,busAssignHdl,outPortHdl2);
                        end
                    end
                    nextYpos=nextYpos+100;
                    connect(blockParentPath,inputMap(inIdx).srcBlkHdl,subsysHdl,inputMap(inIdx).srcBlkPort,num2str(inIdx));
                end

                connect(blockParentPath,subsysHdl,outputLineDstBlk,'1',outputLineDstPortName);
            end

            function fwdTopic(baseName,fromTopic,toTopic,fromQos,toQos,recvBlkPos,inSuffix,outSuffix,inIdx,outIdx,refBlk)
                newRecvBlkName=[h.DDSAdaptiveFwd,'/',baseName,'Recv'];
                if h.UseCoreMessageBlock
                    newRecvBlkHdl=add_block('built-in/Receive',...
                    newRecvBlkName,'MakeNameUnique','on',...
                    'Position',recvBlkPos);
                    set_param(newRecvBlkHdl,'UseInternalQueue','off');
                    set_param(newRecvBlkHdl,'ValueSourceWhenQueueIsEmpty','Hold last value');
                else
                    newRecvBlkHdl=add_block('ddsblock/Take DDS Sample',...
                    newRecvBlkName,'MakeNameUnique','on',...
                    'Position',recvBlkPos);
                end
                set_param(newRecvBlkHdl,'ShowQueueStatus','on');

                newRecvBlkPorts=get_param(newRecvBlkHdl,'PortHandles');
                newRecbBlkOutPortPos=get_param(newRecvBlkPorts.Inport,'Position');
                portRecvPos=[newRecbBlkOutPortPos(1)-65,newRecbBlkOutPortPos(2)-10,newRecbBlkOutPortPos(1)-35,newRecbBlkOutPortPos(2)+10];
                portRecvName=[h.DDSAdaptiveFwd,'/',baseName,inSuffix];
                inportRecvHdl=add_block('built-in/Inport',portRecvName,'MakeNameUnique','on','Position',portRecvPos);
                connect(h.DDSAdaptiveFwd,inportRecvHdl,newRecvBlkHdl);


                newSendPos=recvBlkPos+[100,0,100,0];
                newSendSubName=[h.DDSAdaptiveFwd,'/',baseName,'Sub'];
                subsysHdlSend=add_block('built-in/Subsystem',newSendSubName,'MakeNameUnique','on','Position',newSendPos);
                add_block('built-in/Enableport',[newSendSubName,'/Enable'],'MakeNameUnique','on','Position',[10,10,40,40]);
                newSendBlockPos=[100,100,170,170];
                newSendBlockName=[newSendSubName,'/Send'];
                if h.UseCoreMessageBlock
                    newSendBlkHdl=add_block('built-in/Send',...
                    newSendBlockName,'MakeNameUnique','on',...
                    'Position',newSendBlockPos);
                else
                    newSendBlkHdl=add_block('ddsblock/Write DDS Sample',...
                    newSendBlockName,'MakeNameUnique','on',...
                    'Position',newSendBlockPos);
                end
                newSendBlkPorts=get_param(newSendBlkHdl,'PortHandles');
                newSendBlkInPortPos=get_param(newSendBlkPorts.Inport,'Position');
                inportSubPos=[newSendBlkInPortPos(1)-65,newSendBlkInPortPos(2)-10,newSendBlkInPortPos(1)-35,newSendBlkInPortPos(2)+10];
                inportSendHdl=add_block('built-in/Inport',[newSendBlockName,'in'],'MakeNameUnique','on','Position',inportSubPos);
                connect(newSendSubName,inportSendHdl,newSendBlkHdl);
                newSendBlkOutPortPos=get_param(newSendBlkPorts.Outport,'Position');
                outportSubPos=[newSendBlkOutPortPos(1)+70,newSendBlkOutPortPos(2)-10,newSendBlkOutPortPos(1)+100,newSendBlkOutPortPos(2)+10];
                outportSendSubHdl=add_block('built-in/Outport',[newSendBlockName,'out'],'MakeNameUnique','on','Position',outportSubPos);
                connect(newSendSubName,newSendBlkHdl,outportSendSubHdl);

                subsysSendPorts=get_param(subsysHdlSend,'PortHandles');
                outPortSubSysPos=get_param(subsysSendPorts.Outport,'Position');
                outportSendPos=[outPortSubSysPos(1)+50,outPortSubSysPos(2)-10,outPortSubSysPos(1)+85,outPortSubSysPos(2)+10];
                outportSendHdl=add_block('built-in/Outport',[h.DDSAdaptiveFwd,'/',baseName,outSuffix],'MakeNameUnique','on','Position',outportSendPos);
                connect(h.DDSAdaptiveFwd,subsysHdlSend,outportSendHdl);
                connect(h.DDSAdaptiveFwd,newRecvBlkHdl,subsysHdlSend,'1','Enable');
                connect(h.DDSAdaptiveFwd,newRecvBlkHdl,subsysHdlSend,'2','1');
                refDataType=get_param(refBlk,'OutDataTypeStr');
                set_param(inportRecvHdl,'OutDataTypeStr',refDataType);
                set_param(inportRecvHdl,'BusOutputAsStruct','On');
                set_param(inportRecvHdl,'SampleTime',get_param(refBlk,'SampleTime'));
                set_param(outportSendHdl,'OutDataTypeStr',refDataType);
                set_param(outportSendHdl,'BusOutputAsStruct','On');

                mappingFwd.sync();
                mappingFwd.Inports(inIdx).MessageCustomization.ConfigurationMode='Use Topic and QoS';
                mappingFwd.Inports(inIdx).MessageCustomization.Topic=fromTopic;
                mappingFwd.Inports(inIdx).MessageCustomization.ReaderWriterQOS=fromQos;
                mappingFwd.Outports(outIdx).MessageCustomization.ConfigurationMode='Use Topic and QoS';
                mappingFwd.Outports(outIdx).MessageCustomization.Topic=toTopic;
                mappingFwd.Outports(outIdx).MessageCustomization.ReaderWriterQOS=toQos;
            end

            [status,msg,msgid]=copyfile([h.ROSModelName,'.slx'],[h.DDSModelName,'.slx']);
            if~status
                error(msgid,strrep(msg,'\','\\'));
            end

            open_system(h.DDSModelName);
            set_param(h.DDSModelName,'HardwareBoard','None');
            set_param(h.DDSModelName,'UseEmbeddedCoderFeatures','On');


            dds.internal.simulink.Util.setupModelForDDS(h.DDSModelName,...
            h.DDSDictConn.filepath,h.SystemName,h.DDSVendor);
            mapping=Simulink.CodeMapping.getCurrentMapping(h.DDSModelName);




            pubBlks=ros.slros.internal.bus.Util.listBlocks(h.DDSModelName,...
            ['(',ros.slros2.internal.block.PublishBlockMask.getMaskType,')']);
            for i=1:numel(pubBlks)
                replacePubBlock(pubBlks{i},mapping);
            end




            subBlks=ros.slros.internal.bus.Util.listBlocks(h.DDSModelName,...
            ['(',ros.slros2.internal.block.SubscribeBlockMask.getMaskType,')']);
            for i=1:numel(subBlks)
                replaceSubBlock(subBlks{i},mapping);
            end



            msgBlks=ros.slros.internal.bus.Util.listBlocks(h.DDSModelName,...
            ['(',ros.slros2.internal.block.MessageBlockMask.MaskType,')']);
            for i=1:numel(msgBlks)
                replaceMsgBlock(msgBlks{i});
            end


            for i=1:numel(mapping.Inports)
                portHdls=get_param(mapping.Inports(i).Block,'PortHandles');
                [~,~,~,dstPortHdl]=getLineEnd(portHdls.Outport(1));
                dstPortPos=get_param(dstPortHdl,'Position');
                curPos=get_param(mapping.Inports(i).Block,'Position');
                newPos=[curPos(1),dstPortPos(2)-10,curPos(3),dstPortPos(2)+10];
                set_param(mapping.Inports(i).Block,'Position',newPos);
            end
            for i=1:numel(mapping.Outports)
                portHdls=get_param(mapping.Outports(i).Block,'PortHandles');
                [~,~,~,srcPortHdl]=getLineSrc(portHdls.Inport(1));
                srcPortPos=get_param(srcPortHdl,'Position');
                curPos=get_param(mapping.Outports(i).Block,'Position');
                newPos=[curPos(1),srcPortPos(2)-10,curPos(3),srcPortPos(2)+10];
                set_param(mapping.Outports(i).Block,'Position',newPos);
            end


            if isequal(get_param(h.DDSModelName,'SaveOutput'),'on')

                set_param(h.DDSModelName,'SaveFormat','Dataset');
            end

            set_param(h.DDSModelName,'ConcurrentTasks','on');
            set_param(h.DDSModelName,'EnableMultiTasking','off');

            if h.CreateFwd

                close_system(h.DDSAdaptiveFwd,0);
                if isfile([h.DDSAdaptiveFwd,'.slx'])
                    delete([h.DDSAdaptiveFwd,'.slx']);
                end
                open_system(new_system(h.DDSAdaptiveFwd));
                set_param(h.DDSAdaptiveFwd,'HardwareBoard','None');
                set_param(h.DDSAdaptiveFwd,'UseEmbeddedCoderFeatures','On');


                dds.internal.simulink.Util.setupModelForDDS(h.DDSAdaptiveFwd,...
                h.DDSDictConn.filepath,h.SystemName,h.DDSVendor);
                set_param(h.DDSAdaptiveFwd,'ConcurrentTasks','on');
                set_param(h.DDSAdaptiveFwd,'EnableMultiTasking','off');


                mapping.sync;
                mappingFwd=Simulink.CodeMapping.getCurrentMapping(h.DDSAdaptiveFwd);

                msgRecvPos=[100,10,170,70];
                fwdInIdx=0;
                fwdOutIdx=0;

                for refInIdx=1:numel(mapping.Inports)
                    msgRecvPos=msgRecvPos+[0,100,0,100];
                    refBlk=mapping.Inports(refInIdx).Block;
                    ROSTopic=mapping.Inports(refInIdx).MessageCustomization.Topic;
                    [topicLibAndPar,topicName]=fileparts(ROSTopic);
                    [topicLib,topicPar]=fileparts(topicLibAndPar);
                    fwdBaseName=[topicPar,'a',topicName];
                    AdaptiveTopic=[topicLib,'/',fwdBaseName];
                    fwdInIdx=fwdInIdx+1;
                    fwdOutIdx=fwdOutIdx+1;
                    fromQos=mapping.Inports(refInIdx).MessageCustomization.ReaderWriterQOS;
                    toQos=[fromQos,'_FWD'];
                    fwdTopic(fwdBaseName,ROSTopic,AdaptiveTopic,fromQos,toQos,msgRecvPos,'ROS','Adaptive',fwdInIdx,fwdOutIdx,refBlk);
                end
                msgRecvPos=[500,10,570,70];

                for refInIdx=1:numel(mapping.Outports)
                    msgRecvPos=msgRecvPos+[0,100,0,100];
                    refBlk=mapping.Outports(refInIdx).Block;
                    ROSTopic=mapping.Outports(refInIdx).MessageCustomization.Topic;
                    [topicLibAndPar,topicName]=fileparts(ROSTopic);
                    [topicLib,topicPar]=fileparts(topicLibAndPar);
                    fwdBaseName=[topicPar,'a',topicName];
                    AdaptiveTopic=[topicLib,'/',fwdBaseName];
                    fwdInIdx=fwdInIdx+1;
                    fwdOutIdx=fwdOutIdx+1;
                    toQos=mapping.Outports(refInIdx).MessageCustomization.ReaderWriterQOS;
                    fromQos=[toQos,'_FWD'];
                    fwdTopic(fwdBaseName,AdaptiveTopic,ROSTopic,fromQos,toQos,msgRecvPos,'Adaptive','ROS',fwdInIdx,fwdOutIdx,refBlk);
                end
            end
        end





        function status=addROSMessage(h,ddsModel,sys,typeLibNode,msgName)
            function rosSimObj=fixDataType(rosSimObj)
                prefix=['Bus: ',ros.slros.internal.bus.Util.BusNamePrefix];
                idxToRemove=[];
                for i=1:numel(rosSimObj.Elements)
                    if startsWith(rosSimObj.Elements(i).DataType,prefix)
                        if isequal(rosSimObj.Elements(i).DataType,'Bus: SL_Bus_ROSVariableLengthArrayInfo')
                            idxToRemove(end+1)=i;%#ok<AGROW> 
                        else
                            rosMsgName=h.getROSMessageFromSimObj(rosSimObj.Elements(i));
                            [~,~,~,~,ddsTypeSimObjName,~,~]=...
                            h.getDDSAndROSNames(rosMsgName);
                            lddsType=['Bus: ',ddsTypeSimObjName];
                            rosSimObj.Elements(i).DataType=lddsType;
                        end
                    elseif startsWith(rosSimObj.Elements(i).Description,'PrimitiveROSType=string')
                        rosSimObj.Elements(i).DataType='string';
                        rosSimObj.Elements(i).Dimensions=1;
                        rosSimObj.Elements(i).Description=regexprep(rosSimObj.Elements(i).Description,...
                        'IsVarLen\s*=\s*1','IsVarLen=0');
                    end
                end
                rosSimObj.Elements(idxToRemove)=[];
            end
            status=false;
            [pkg,~,ddsTypeFullPath,ddsTypeParent,~,ddsName,rosTypeName]=...
            h.getDDSAndROSNames(msgName);
            rosSimObj=ros.slros2.internal.bus.Util.getBusObjectFromBusName(rosTypeName,'');


            ddsNode=sys(1);

            ddsType=dds.internal.simulink.Util.findType(ddsNode,ddsTypeFullPath);
            if~isempty(ddsType)

                return;
            end

            new_ddsNodeDDS=dds.internal.simulink.Util.findType(ddsNode,ddsTypeParent);
            if~isa(new_ddsNodeDDS,'dds.datamodel.types.Module')
                if ddsNode==sys(1)
                    ddsNode=typeLibNode;
                end
                new_ddsNodePkg=dds.internal.simulink.ui.internal.dds.datamodel.types.Module.create(ddsModel,[],ddsNode,pkg);
                ddsNode.Elements.add(new_ddsNodePkg);
                new_ddsNodeMsg=dds.internal.simulink.ui.internal.dds.datamodel.types.Module.create(ddsModel,[],new_ddsNodePkg,'msg');
                new_ddsNodePkg.Elements.add(new_ddsNodeMsg);
                new_ddsNodeDDS=dds.internal.simulink.ui.internal.dds.datamodel.types.Module.create(ddsModel,[],new_ddsNodeMsg,'dds_');
                new_ddsNodeMsg.Elements.add(new_ddsNodeDDS);
            end
            ddsNode=new_ddsNodeDDS;


            types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList(ddsNode);
            if isa(rosSimObj,'Simulink.Bus')
                ddsObject=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,types,'dds.datamodel.types.Struct',ddsName);


                element=dds.datamodel.types.StructMember(ddsModel);
                element.Name='Element1';
                element.Id=0;
                element.Index=1;
                element.Key=1;
                element.Type=dds.datamodel.types.Integer(ddsModel);
                ddsObject.Members.add(element);

            elseif isa(rosBusObj,'Simulink.data.dictionary.EnumTypeDefinition')
                ddsObject=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,types,'dds.datamodel.types.Enum',ddsName);
                ddsObject.Base=dds.datamodel.types.Integer(ddsModel);

                element=dds.datamodel.types.EnumMember(ddsModel);
                element.Name='Element1';
                element.Index=1;
                element.ValueStr='0';
                ddsObject.Members.add(element);

            else
                ddsObject=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,types,'dds.datamodel.types.Const',ddsName);
                ddsObject.Type=dds.datamodel.types.Integer(ddsModel);
                ddsObject.ValueStr='0';
            end


            ddsNode.Elements.add(ddsObject);

            updateVisitor=dds.internal.simulink.UpdateSimObjectsVisitor();
            updateVisitor.addSimObject(ddsObject,fixDataType(rosSimObj),true);
            updateVisitor.visitModel(ddsModel);

            status=true;
        end


        function status=addToGraph(h,graphName,nodeName,depName)
            graph=h.(graphName);
            nodeList=graph.Nodes.Variables;
            if~isempty(nodeList)
                match=cellfun(@(x)isequal(nodeName,x),nodeList);
            end
            if isempty(nodeList)||~any(match)
                graph=graph.addnode(nodeName);
            end
            if~isempty(depName)
                graph=graph.addedge(depName,nodeName);
            end
            h.(graphName)=graph;
            status=true;
        end



        function status=addROSTopic(h,ddsModel,sys,domain,topicName)
            entry=h.ROSTopicsAndType(topicName);
            names=cell(1,7);
            [names{:}]=h.getDDSAndROSNames(entry.msgType);
            typeRef=dds.internal.simulink.Util.findType(sys,names{3});
            registerType=domain.RegisterTypes{names{5}};
            if isempty(registerType)
                registerType=dds.datamodel.domain.RegisterType(ddsModel);
                registerType.Name=names{5};


                registerType.OriginalName=names{3};
                registerType.TypeRef=typeRef;
                domain.RegisterTypes.add(registerType);
            else
                assert(registerType.TypeRef==typeRef);
            end

            ddsTopicName=h.getDDSTopic(topicName);
            topic=domain.Topics{ddsTopicName};
            if isempty(topic)
                topic=dds.datamodel.domain.Topic(ddsModel);
                topic.Name=ddsTopicName;
                topic.RegisterTypeRef=registerType;
                domain.Topics.add(topic);
            else
                assert(topic.RegisterTypeRef==registerType);
            end

            if h.CreateFwd


                registerTypeFwdName=[names{5},'_a'];
                registerTypeFwd=domain.RegisterTypes{registerTypeFwdName};
                if isempty(registerTypeFwd)
                    registerTypeFwd=dds.datamodel.domain.RegisterType(ddsModel);
                    registerTypeFwd.Name=registerTypeFwdName;
                    registerTypeFwd.OriginalName=names{5};
                    registerTypeFwd.TypeRef=typeRef;
                    domain.RegisterTypes.add(registerTypeFwd);
                else
                    assert(registerTypeFwd.TypeRef==typeRef);
                end

                ddsTopicFwdName=strrep(ddsTopicName,'/','a');
                topicFwd=domain.Topics{ddsTopicFwdName};
                if isempty(topicFwd)
                    topicFwd=dds.datamodel.domain.Topic(ddsModel);
                    topicFwd.Name=ddsTopicFwdName;
                    topicFwd.RegisterTypeRef=registerTypeFwd;
                    domain.Topics.add(topicFwd);
                else
                    assert(topicFwd.RegisterTypeRef==registerTypeFwd);
                end
            end

            status=true;
        end


        function qosLibName=getQosLibName(h)
            qosLibName=[h.SystemName,'_qos'];
        end


        function sortList=getSortedList(h,graphName)
            simpG=h.(graphName).simplify;
            [~,sortedG]=simpG.toposort();
            sortList=sortedG.Nodes.Variables;
        end


        function parseInputs(h,varargin)
            parser=inputParser;
            parser.addRequired('rosModel',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('system','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('vendor','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('ddsModel','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('ddsDict','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('useCoreMsg','',@(x)validateattributes(x,{'logical'},{'nonempty'}));
            parser.addParameter('createForward','',@(x)validateattributes(x,{'logical'},{'nonempty'}));
            parser.parse(varargin{:});



            h.ROSModelName=parser.Results.rosModel;


            if~isempty(parser.Results.system)
                h.SystemName=parser.Results.system;
            else
                h.SystemName=h.ROSModelName;
            end

            if~isempty(parser.Results.useCoreMsg)
                h.UseCoreMessageBlock=parser.Results.useCoreMsg;
            else


                h.UseCoreMessageBlock=true;
            end

            if~isempty(parser.Results.createForward)
                h.CreateFwd=parser.Results.createForward;
            else
                h.CreateFwd=false;
            end


            reg=dds.internal.vendor.DDSRegistry;
            lst=reg.getVendorList;
            if~isempty(parser.Results.vendor)
                idx=find(strcmp({lst(:).DisplayName},parser.Results.vendor),1);
                if isempty(idx)
                    h.DDSVendor=lst(1).Key;
                else
                    h.DDSVendor=lst(idx).Key;
                end
            else
                h.DDSVendor=lst(1).Key;
            end


            if~isempty(parser.Results.ddsModel)
                h.DDSModelName=parser.Results.ddsModel;
            else
                [~,baseName,~]=fileparts(h.ROSModelName);
                h.DDSModelName=[baseName,'_DDS'];
            end


            if~isempty(parser.Results.ddsDict)
                h.DDSDictionaryName=parser.Results.ddsDict;
            else
                h.DDSDictionaryName=[h.DDSModelName,'.sldd'];
            end

            if h.CreateFwd
                h.DDSAdaptiveFwd=[h.DDSModelName,'_FWD'];
            else
                h.DDSAdaptiveFwd='';
            end
        end
    end

    methods(Static)

        function[pkg,msgName,ddsTypeFullPath,ddsTypeParent,ddsTypeSimObjName,ddsName,rosTypeName]=getDDSAndROSNames(rosMsg)
            [pkg,msgName]=fileparts(rosMsg);
            ddsTypeFullPath=[pkg,'::msg::dds_::',msgName,'_'];
            ddsTypeParent=[pkg,'::msg::dds_'];
            ddsTypeSimObjName=[pkg,'_msg_dds__',msgName,'_'];
            ddsName=[msgName,'_'];
            rosTypeName=ros.slros2.internal.bus.Util.rosMsgTypeToBusName(rosMsg);
        end


        function ddsDomainName=getDDSDomain()
            ddsDomainName='rt';
        end


        function ddsTopicName=getDDSTopic(rosTopic)
            [~,ddsTopicName]=fileparts(rosTopic);

            ddsTopicName=[dds.internal.simulink.ros.Migrator.getDDSDomain(),'/',ddsTopicName];
        end


        function qosName=getQoSName(rosBlkName,rootNameToRemove)
            qosName=strrep(rosBlkName,'/','_');
            qosName=strrep(qosName,[rootNameToRemove,'_'],'');
        end




        function msgType=getROSMessageFromSimObj(simObj)

            msgType='';
            if isprop(simObj,'Description')&&contains(simObj.Description,'MsgType=')
                descSplit=strsplit(simObj.Description,'=');
                msgType=descSplit{2};
                if contains(msgType,':')
                    msgTypeSplit=strsplit(msgType,':');
                    msgType=msgTypeSplit{1};
                end
            end
        end

        function isSLInfo=getIsSLInfo(signalName)
            isSLInfo=false;
            [~,splitStr,~]=fileparts(signalName);
            if~isempty(splitStr)
                isSLInfo=endsWith(splitStr,"_SL_Info");
            end
        end

        function useBEP=getCanUseBEP(signalName)
            useBEP=true;
            [~,splitStr,~]=fileparts(signalName);
            if~isempty(splitStr)
                useBEP=~endsWith(splitStr,"MultiArray_");
            end
        end
    end
end



























