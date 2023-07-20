classdef SLConnector<handle





    properties(Access=private)
        ModelName;
        UpdateMode;
        ChangeLogger;
        SLMatcher;
        AddedSignalLines;
        M3IComposition;
        SlModelBlockToM3ICompPrototypeMap;
    end

    methods(Access=public)
        function this=SLConnector(modelName,updateMode,changeLogger,...
            slMatcher,m3iComposition,slModelBlockToM3ICompPrototypeMap)
            this.ModelName=modelName;
            this.UpdateMode=updateMode;
            this.ChangeLogger=changeLogger;
            this.SLMatcher=slMatcher;
            this.AddedSignalLines=[];
            this.M3IComposition=m3iComposition;
            this.SlModelBlockToM3ICompPrototypeMap=slModelBlockToM3ICompPrototypeMap;
        end

        function connectPortsUsingConnector(this,m3iConnector)







            [canImportConnector,m3iComp1,m3iPort1,m3iComp2,m3iPort2,connectionType]=...
            this.checkConnectionCanBeImported(m3iConnector);

            if~canImportConnector

                return;
            end

            port1dataElementToSlPortMap=this.getDataElementToSlPortMap(m3iComp1,m3iPort1);
            port2dataElementToSlPortMap=this.getDataElementToSlPortMap(m3iComp2,m3iPort2);
            this.findSlPortsTobeConnected(port1dataElementToSlPortMap,...
            port2dataElementToSlPortMap,connectionType);
        end


        function connectPortsUsingConnectorInArchModel(this,m3iConnector,slConnectorParentH)


            function compObj=getCompObject(rootComposition,m3iComp)
                if isa(m3iComp,'Simulink.metamodel.arplatform.composition.ComponentPrototype')
                    if autosar.composition.Utils.isM3ICompositionPrototype(m3iComp)

                        compObj=rootComposition.find('Composition','Name',m3iComp.Type.Name);
                    else
                        compObj=rootComposition.find('Component','Name',m3iComp.Name);
                    end
                else
                    compObj=rootComposition;
                end
            end

            [canImportConnector,m3iComp1,m3iPort1,m3iComp2,m3iPort2,connectionType]=...
            this.checkConnectionCanBeImported(m3iConnector);

            if~canImportConnector

                return;
            end

            compositionObj=autosar.arch.Composition.create(slConnectorParentH);

            compObj1=getCompObject(compositionObj,m3iComp1);
            compObj2=getCompObject(compositionObj,m3iComp2);

            if isempty(compObj1)||isempty(compObj2)
                return;
            end

            [portObj1,portObj2]=...
            autosar.composition.mm2sl.SLConnector.findPortsToConnect(...
            compObj1,compObj2,m3iComp1,m3iComp2,m3iPort1,m3iPort2,connectionType);

            if isempty(portObj1)||isempty(portObj2)
                return;
            end

            compositionObj.connect(portObj1,portObj2);




            MG2.syncOnGuiPingPong();
        end


        function connectPRPortsForAllCompPrototypes(this)
            slModelBlocks=this.SlModelBlockToM3ICompPrototypeMap.keys;
            m3iPrototypes=this.SlModelBlockToM3ICompPrototypeMap.values;
            for i=1:length(slModelBlocks)
                this.connectPRPortsForCompPrototype(m3iPrototypes{i})
            end
        end

        function addLines(this)

            for lineIdx=1:length(this.AddedSignalLines)
                sigLine=this.AddedSignalLines(lineIdx);






                if this.UpdateMode
                    dstPortH=sigLine.getDstPortHandle();
                    if dstPortH~=-1
                        srcBlockH=get(dstPortH,'SrcBlockHandle');
                        if srcBlockH==-1

                            sigLine.deleteLine();
                        else
                            if strcmp(get_param(srcBlockH,'BlockType'),'Ground')
                                [numConnections,lineH]=autosar.mm.mm2sl.MRLayoutManager.numConnections(srcBlockH);
                                if(numConnections==1)


                                    groundToModelBlockLine=autosar.composition.mm2sl.SLSignalLine(...
                                    this.ModelName,[get_param(srcBlockH,'Name'),'/1'],sigLine.DstPort);
                                    this.ChangeLogger.logDeletion('Automatic',...
                                    message('RTW:autosar:updateReportSignalLineLabel').getString(),...
                                    groundToModelBlockLine.getLineLabel());
                                    this.ChangeLogger.logDeletion('Automatic','Block',getfullname(srcBlockH));


                                    delete_line(lineH);
                                    delete_block(srcBlockH);
                                end
                            end
                        end
                    end
                end

                dstHasConnections=sigLine.getDstPortHandle()~=-1;
                if~dstHasConnections

                    if sigLine.isLoopbackConnection


                        latchBlkH=add_block('built-in/FunctionCallFeedbackLatch',...
                        [sigLine.ParentName,'/',sprintf('Function-Call\nFeedback Latch')],...
                        'MakeNameUnique','on');
                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(sigLine.ParentName,...
                        sigLine.SrcPort,[get_param(latchBlkH,'Name'),'/1']);
                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(sigLine.ParentName,...
                        [get_param(latchBlkH,'Name'),'/1'],sigLine.DstPort);
                    else
                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(sigLine.ParentName,sigLine.SrcPort,sigLine.DstPort);
                    end

                    if this.UpdateMode

                        this.ChangeLogger.logAddition('Automatic',...
                        message('RTW:autosar:updateReportSignalLineLabel').getString(),...
                        autosar.updater.Report.getMATLABHyperlink(...
                        sigLine.getHiliteLineCommand(),...
                        sigLine.getLineLabel()));
                    end
                else



                    autosar.mm.util.MessageReporter.createWarning(...
                    'autosarstandard:importer:ConnectorCannotMergeSignalLines',...
                    sigLine.SrcPort,sigLine.DstPort,this.ModelName);
                end
            end
        end

        function markupAddedLines(this)

            for lineIdx=1:length(this.AddedSignalLines)
                autosar.mm.mm2sl.SLModelBuilder.createAddedLineSimulinkArea(...
                this.AddedSignalLines(lineIdx).getLineHandle());
            end
        end
    end

    methods(Static)



        function needWire=portRequiresWiredConnection(m3iPort)
            needWire=~(isa(m3iPort,'Simulink.metamodel.arplatform.port.ClientPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.ServerPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.TriggerReceiverPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.ParameterReceiverPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.ParameterSenderPort'));
        end
    end

    methods(Access=private)

        function[canImportConnector,m3iComp1,m3iPort1,m3iComp2,m3iPort2,connectionType]=...
            checkConnectionCanBeImported(this,m3iConnector)

            canImportConnector=false;
            [m3iComp1,m3iPort1,m3iComp2,m3iPort2,connectionType]=...
            this.getSrcAndDstComponentsAndPorts(m3iConnector);



            if~(autosar.composition.mm2sl.SLConnector.portRequiresWiredConnection(m3iPort1)&&...
                autosar.composition.mm2sl.SLConnector.portRequiresWiredConnection(m3iPort2))
                return;
            end


            if~autosar.composition.mm2sl.SLConnector.arePortInterfacesCompatible(m3iPort1,m3iPort2)
                autosar.mm.util.MessageReporter.createWarning(...
                'autosarstandard:importer:IncompatiblePortInterfaces',...
                m3iConnector.Name,...
                autosar.api.Utils.getQualifiedName(this.M3IComposition),...
                this.ModelName,...
                autosar.api.Utils.getQualifiedName(m3iPort1),...
                autosar.api.Utils.getQualifiedName(m3iPort1.Interface),...
                m3iPort1.Interface.MetaClass.name,...
                autosar.api.Utils.getQualifiedName(m3iPort2),...
                autosar.api.Utils.getQualifiedName(m3iPort2.Interface),...
                m3iPort2.Interface.MetaClass.name);
                return;
            end






            if isa(m3iPort2,'Simulink.metamodel.arplatform.port.ProvidedRequiredPort')
                autosar.mm.util.MessageReporter.createWarning(...
                'autosarstandard:importer:UnableToModelProvidedRequiredPort',...
                m3iConnector.Name,...
                autosar.api.Utils.getQualifiedName(this.M3IComposition),...
                autosar.api.Utils.getQualifiedName(m3iPort2));
                return;
            end


            if autosar.composition.Utils.isModelInCompositionDomain(this.ModelName)
                if isa(m3iPort1,'Simulink.metamodel.arplatform.port.ProvidedRequiredPort')
                    autosar.mm.util.MessageReporter.createWarning(...
                    'autosarstandard:importer:UnableToModelProvidedRequiredPort',...
                    m3iConnector.Name,...
                    autosar.api.Utils.getQualifiedName(this.M3IComposition),...
                    autosar.api.Utils.getQualifiedName(m3iPort1));
                    return;
                end

                if isa(m3iPort2,'Simulink.metamodel.arplatform.port.ProvidedRequiredPort')
                    autosar.mm.util.MessageReporter.createWarning(...
                    'autosarstandard:importer:UnableToModelProvidedRequiredPort',...
                    m3iConnector.Name,...
                    autosar.api.Utils.getQualifiedName(this.M3IComposition),...
                    autosar.api.Utils.getQualifiedName(m3iPort2));
                    return;
                end
            end

            canImportConnector=true;
        end



        function connectPRPortsForCompPrototype(this,m3iCompProto)
            m3iComp=m3iCompProto.Type;
            m3iPRPorts=autosar.mm.Model.findObjectByMetaClass(m3iComp,...
            Simulink.metamodel.arplatform.port.ProvidedRequiredPort.MetaClass,true,true);
            for i=1:m3iPRPorts.size()
                m3iPRPort=m3iPRPorts.at(i);


                if~autosar.composition.mm2sl.SLConnector.portRequiresWiredConnection(m3iPRPort)
                    continue;
                end

                portDataElementToSlPortMap=this.getDataElementToSlPortMap(m3iCompProto,m3iPRPort);
                portDataElements=portDataElementToSlPortMap.keys;
                for keyIdx=1:numel(portDataElements)
                    slPorts=portDataElementToSlPortMap(portDataElements{keyIdx});
                    if length(slPorts)==2
                        this.collectLineForAddition(slPorts{1},slPorts{2},'Assembly');
                    end
                end
            end
        end





        function dataElementToSlPortMap=getDataElementToSlPortMap(this,m3iComp,m3iPort)

            dataElementToSlPortMap=containers.Map();


            if isa(m3iComp,'Simulink.metamodel.arplatform.composition.ComponentPrototype')




                m3iPrototypes=this.SlModelBlockToM3ICompPrototypeMap.values;
                slModelBlocks=this.SlModelBlockToM3ICompPrototypeMap.keys;
                slModelBlock=slModelBlocks(cellfun(@(x)(x==m3iComp),m3iPrototypes));
                assert(length(slModelBlock)==1,'Could not find Model block for component prototype %s',m3iComp.Name);
                slModelBlock=slModelBlock{1};
                modelBlockName=get_param(slModelBlock,'Name');
                refModel=get_param(slModelBlock,'ModelName');
                mapping=autosar.api.Utils.modelMapping(refModel);
            else

                mapping=autosar.api.Utils.modelMapping(this.ModelName);
            end


            if isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedRequiredPort')
                blockMapping=[mapping.Inports,mapping.Outports];
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.RequiredPort')
                blockMapping=mapping.Inports;
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedPort')
                blockMapping=mapping.Outports;
            else
                assert(false,'Unexpected port type %s',class(m3iPort));
            end


            for i=1:length(blockMapping)
                if strcmp(blockMapping(i).MappedTo.Port,m3iPort.Name)
                    slBlock=blockMapping(i).Block;
                    if strcmp(blockMapping(i).MappedTo.DataAccessMode,'IsUpdated')
                        dataElementName=[blockMapping(i).MappedTo.Element,'_IsUpdated'];
                    elseif strcmp(blockMapping(i).MappedTo.DataAccessMode,'ErrorStatus')
                        dataElementName=[blockMapping(i).MappedTo.Element,'_ErrorStatus'];
                    else
                        dataElementName=blockMapping(i).MappedTo.Element;
                    end
                    if isa(m3iComp,'Simulink.metamodel.arplatform.composition.ComponentPrototype')

                        slPortInfo=struct('SLPort',slBlock,...
                        'PortConnectivity',[modelBlockName,'/',get_param(slBlock,'Port')]);
                    else

                        slPortInfo=struct('SLPort',slBlock,...
                        'PortConnectivity',[get_param(slBlock,'Name'),'/1']);
                    end


                    if dataElementToSlPortMap.isKey(dataElementName)

                        dataElementToSlPortMap(dataElementName)=[dataElementToSlPortMap(dataElementName),{slPortInfo}];
                    else
                        dataElementToSlPortMap(dataElementName)={slPortInfo};
                    end
                end
            end
        end



        function findSlPortsTobeConnected(this,port1dataElementsToSlPortMap,...
            port2dataElementsToSlPortMap,connectionType)
            port1DataElements=port1dataElementsToSlPortMap.keys;
            for keyIdx=1:numel(port1DataElements)
                key=port1DataElements{keyIdx};
                if port2dataElementsToSlPortMap.isKey(key)
                    slPorts1=port1dataElementsToSlPortMap(key);
                    slPorts2=port2dataElementsToSlPortMap(key);
                    if(numel(slPorts1)==1)&&(numel(slPorts2)==1)
                        this.collectLineForAddition(slPorts1{1},slPorts2{1},connectionType);
                    elseif(numel(slPorts1)==2)&&(numel(slPorts2)==1)


                        assert(strcmp(get_param(slPorts1{2}.SLPort,'BlockType'),'Outport'));
                        this.collectLineForAddition(slPorts1{2},slPorts2{1},connectionType);
                    end
                end
            end
        end




        function collectLineForAddition(this,slPort1,slPort2,connectionType)
            if strcmp(get_param(slPort1.SLPort,'BlockType'),'Inport')&&...
                strcmp(get_param(slPort2.SLPort,'BlockType'),'Outport')


                if strcmp(connectionType,'PassThrough')
                    src=slPort1.PortConnectivity;
                    dst=slPort2.PortConnectivity;
                elseif strcmp(connectionType,'Assembly')
                    src=slPort2.PortConnectivity;
                    dst=slPort1.PortConnectivity;
                else

                    return;
                end
            elseif strcmp(get_param(slPort1.SLPort,'BlockType'),'Outport')&&...
                strcmp(get_param(slPort2.SLPort,'BlockType'),'Inport')


                if strcmp(connectionType,'PassThrough')
                    src=slPort2.PortConnectivity;
                    dst=slPort1.PortConnectivity;
                elseif strcmp(connectionType,'Assembly')
                    src=slPort1.PortConnectivity;
                    dst=slPort2.PortConnectivity;
                else

                    return;
                end
            elseif strcmp(get_param(slPort1.SLPort,'BlockType'),'Inport')&&...
                strcmp(get_param(slPort2.SLPort,'BlockType'),'Inport')
                if~strcmp(connectionType,'Delegation')

                    return;
                end
                if strcmp(get_param(slPort1.SLPort,'Parent'),this.ModelName)
                    src=slPort1.PortConnectivity;
                    dst=slPort2.PortConnectivity;
                else
                    src=slPort2.PortConnectivity;
                    dst=slPort1.PortConnectivity;
                end
            elseif strcmp(get_param(slPort1.SLPort,'BlockType'),'Outport')&&...
                strcmp(get_param(slPort2.SLPort,'BlockType'),'Outport')
                if~strcmp(connectionType,'Delegation')

                    return;
                end
                if strcmp(get_param(slPort1.SLPort,'Parent'),this.ModelName)
                    src=slPort2.PortConnectivity;
                    dst=slPort1.PortConnectivity;
                else
                    src=slPort1.PortConnectivity;
                    dst=slPort2.PortConnectivity;
                end
            end


            slSignalLine=autosar.composition.mm2sl.SLSignalLine(this.ModelName,src,dst);
            lineAlreadyExists=false;
            if this.UpdateMode&&this.SLMatcher.isSignalLineMapped(slSignalLine)
                this.SLMatcher.markSignalLineMatched(slSignalLine);
                lineAlreadyExists=true;
            end

            if~lineAlreadyExists
                this.AddedSignalLines=[this.AddedSignalLines,slSignalLine];
            end
        end



        function[m3iComp1,m3iPort1,m3iComp2,m3iPort2,connectionType]=...
            getSrcAndDstComponentsAndPorts(this,m3iConnector)

            switch(class(m3iConnector))
            case 'Simulink.metamodel.arplatform.composition.AssemblyConnector'

                m3iComp1=m3iConnector.Provider.ComponentPrototype;
                m3iComp2=m3iConnector.Requester.ComponentPrototype;
                m3iPort1=m3iConnector.Provider.ProvidedPort;
                m3iPort2=m3iConnector.Requester.RequiredPort;
                connectionType='Assembly';
            case 'Simulink.metamodel.arplatform.composition.DelegationConnector'

                innerComp=m3iConnector.InnerPort.ComponentPrototype;
                outerPort=m3iConnector.OuterPort;
                innerPortIref=m3iConnector.InnerPort;


                if isa(innerPortIref,'Simulink.metamodel.arplatform.instance.CompositionRPortInstanceRef')

                    innerPort=innerPortIref.RequiredPort;
                    m3iComp1=this.M3IComposition;
                    m3iPort1=outerPort;
                    m3iComp2=innerComp;
                    m3iPort2=innerPort;
                elseif isa(innerPortIref,'Simulink.metamodel.arplatform.instance.CompositionPPortInstanceRef')

                    innerPort=innerPortIref.ProvidedPort;
                    m3iComp1=innerComp;
                    m3iPort1=innerPort;
                    m3iComp2=this.M3IComposition;
                    m3iPort2=outerPort;
                else
                    assert(false,'Unexpected InnerPortIref type "%s".',class(innerPortIref));
                end
                connectionType='Delegation';
            otherwise
                assert(false,'Unexpected m3iConnector type "%s".',class(m3iConnector));
            end
        end
    end

    methods(Static,Access=private)
        function compatible=arePortInterfacesCompatible(port1,port2)




            port1Interface=port1.Interface;
            port2Interface=port2.Interface;


            if isequal(class(port1Interface),class(port2Interface))
                compatible=true;
                return;
            end


            if(isa(port1Interface,'Simulink.metamodel.arplatform.interface.SenderReceiverInterface')&&...
                isa(port2Interface,'Simulink.metamodel.arplatform.interface.NvDataInterface'))||...
                (isa(port2Interface,'Simulink.metamodel.arplatform.interface.SenderReceiverInterface')&&...
                isa(port1Interface,'Simulink.metamodel.arplatform.interface.NvDataInterface'))
                compatible=true;
                return;
            end

            compatible=false;
        end

        function slPort=findPortWithType(slPorts,portType)
            slPort=[];
            matchingPorts=cellfun(@(x)strcmp(get_param(x.SLPort,...
            'BlockType'),portType),slPorts,'UniformOutput',false);
            matchingPortsIdx=find([matchingPorts{:}]);
            if~isempty(matchingPortsIdx)
                slPort=slPorts{matchingPortsIdx(1)};
            end
        end

        function[portObj1,portObj2]=findPortsToConnect(compObj1,compObj2,m3iComp1,m3iComp2,m3iPort1,m3iPort2,connectionType)










            portObj1=compObj1.find('Port','Name',m3iPort1.Name);
            portObj2=compObj2.find('Port','Name',m3iPort2.Name);

            if isempty(portObj1)||isempty(portObj2)
                return;
            end

            portObj1=autosar.composition.mm2sl.SLConnector.getConnectablePort(portObj1,m3iComp1,connectionType);
            portObj2=autosar.composition.mm2sl.SLConnector.getConnectablePort(portObj2,m3iComp2,connectionType);
        end

        function portObj=getConnectablePort(portObj,m3iComp,connectionType)



            if strcmp(connectionType,'Delegation')
                if autosar.composition.Utils.isM3IComposition(m3iComp)
                    if~isa(portObj,'autosar.arch.ArchPort')
                        portBlk=autosar.arch.Utils.findSLPortBlock(portObj.SimulinkHandle);
                        portBlk=portBlk{1};
                        portObj=autosar.arch.ArchPort.create(portBlk);
                    end



                    portObj=autosar.composition.mm2sl.SLConnector.getUnconnectedChevron(portObj);
                end
            end
        end

        function portObj=getUnconnectedChevron(portObj)



            if any([portObj.Connected])
                existingBlock=getfullname(portObj(1).SimulinkHandle);
                newBlock=add_block(existingBlock,existingBlock,'MakeNameUnique','on');
                portObj=autosar.arch.ArchPort.create(newBlock);
            end
        end
    end
end



