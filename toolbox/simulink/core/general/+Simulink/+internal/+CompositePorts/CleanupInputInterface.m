classdef(Sealed)CleanupInputInterface<Simulink.internal.CompositePorts.InterfaceAction

    methods(Access={?Simulink.internal.CompositePorts.CleanupInterfaceWrapper})

        function this=CleanupInputInterface(editor,selection)
            narginchk(2,2);



            this@Simulink.internal.CompositePorts.InterfaceAction(editor,selection,mfilename('class'));



            this.mData.busSelector=-1;
            this.mData.srcBlock=-1;
            this.mData.inportBlock=-1;
            this.mData.portBlocks=[];

            pickBusSelector(this);

            pickInport(this);
        end
    end


    methods(Access=protected)
        function m=getEditorModels(this)
            m={this.mData.editor.getDiagram().model.getRootDeviant()};
        end
    end


    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        function tf=canExecuteImpl(this)





            isTopLevel=this.mData.editor.getDiagram().isTopLevel();
            isStateflowBlock=~isTopLevel&&...
            this.isStateflowBlock(get_param(get_param(this.mData.inportBlock,'Parent'),'Parent'));
            isForEachSubsystem=~isTopLevel&&...
            Simulink.BlockDiagram.Internal.isForEachSubsystem(get_param(get_param(this.mData.inportBlock,'Parent'),'Handle'));

            tf=ishandle(this.mData.busSelector)&&...
            ishandle(this.mData.inportBlock)&&...
            ~isStateflowBlock&&...
            ~isForEachSubsystem;
        end


        function msg=executeImpl(this)

            msg=this.getWarningsIfNotSupported();
            if~isempty(msg)
                return;
            end


            this.constructActionInfo();


            lines=get_param(this.mData.busSelector,'LineHandles');
            this.deleteDiagramElement(this.mData.editor,lines.Inport);

            if slsvTestingHook('BusActionsThrowBeforeChange')==1
                assert(false)
            end


            this.mData.modeledPortBlocks=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(this.mData.portBlocks(1));


            isComposite=get_param(this.mData.portBlocks(1),'IsComposite');




            this.mData.newBlockHandles=this.expandPortBlock(this.mData.editor,[this.mData.portBlocks,this.mData.busSelector],'',this.mData.signalNames,this.mData.newBlockPositions,this.mData.orientations);





            interfaceBlock=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(this.mData.newBlockHandles(1));

            port=interfaceBlock.port;
            tree=port.tree;


            elemNode=Simulink.internal.CompositePorts.TreeNode.findNode(tree,this.mData.element);



            if strcmp(isComposite,'off')
                if isfield(this.mData,'elemDataType')
                    elemDataType=this.mData.elemDataType;
                else
                    elemDataType='Inherit: auto';
                end
                Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(elemNode,elemDataType);

                if startsWith(elemDataType,'Bus: ')
                    if isfield(this.mData,'elemVirtuality')&&strcmpi(this.mData.elemVirtuality,'on')
                        elemVirtuality=sl.mfzero.treeNode.Virtuality.NON_VIRTUAL;
                        Simulink.internal.CompositePorts.TreeNode.setVirtualityCL(elemNode,elemVirtuality);

                        if isfield(this.mData,'elemDims')&&strcmpi(this.mData.elemDims,'1')
                            elemDims=this.mData.elemDims;
                            Simulink.internal.CompositePorts.TreeNode.setDimsCL(elemNode,elemDims);
                        end

                        if isfield(this.mData,'elemSampleTime')
                            elemSampleTime=this.mData.elemSampleTime;
                            Simulink.internal.CompositePorts.TreeNode.setSampleTimeCL(elemNode,elemSampleTime);
                        end
                    else
                        elemVirtuality=sl.mfzero.treeNode.Virtuality.INHERIT;
                        Simulink.internal.CompositePorts.TreeNode.setVirtualityCL(elemNode,elemVirtuality);
                    end
                end
            end


            this.makeConnections();


            this.mData.editor.clearSelection();


            for i=this.mData.numElements:-1:1
                this.mData.editor.select(SLM3I.SLDomain.handle2DiagramElement(this.mData.newBlockHandles(i)));
            end

            if slsvTestingHook('BusActionsThrowAfterChange')==1
                assert(false)
            end
        end
    end


    methods(Access=private)

        function pickBusSelector(this)

            h=this.getBlocksOfType(this.mData.selection,'BusSelector');

            if isempty(h)||numel(h)~=1
                return;
            end


            src=this.getSrcBlocks(h);
            src=src{1};
            if numel(src)~=1
                return;
            end


            if~ishandle(src)||~(strcmp(get_param(src,'BlockType'),'Inport')||strcmp(get_param(src,'BlockType'),'InportShadow'))
                return;
            end
            this.mData.srcBlock=src;


            this.mData.busSelector=h;




            this.mData.signalNames=split(get_param(this.mData.busSelector,'OutputSignals'),',')';
        end


        function pickInport(this)

            this.mData.inportBlock=-1;


            if~ishandle(this.mData.busSelector)||~ishandle(this.mData.srcBlock)
                return;
            end


            subsysOrEnclosingModelHandle=get_param(get_param(this.mData.srcBlock,'Parent'),'Handle');
            portnum=str2double(get_param(this.mData.srcBlock,'Port'));
            if strcmp(get_param(this.mData.srcBlock,'IsComposite'),'off')

                portBlocks=Simulink.BlockDiagram.Internal.getBlocksOfInputPort...
                (subsysOrEnclosingModelHandle,portnum);
            else

                portBlocks=[this.mData.srcBlock];
            end






            assert(isempty(portBlocks)||strcmp(get_param(portBlocks(1),'BlockType'),'Inport'));


            this.mData.inportBlock=this.mData.srcBlock;
            this.mData.portBlocks=portBlocks;
        end

        function msg=getWarningsIfNotSupported(this)
            msg='';


            conExecMsg='';
            m=bdroot(this.mData.busSelector);
            if this.isConcurrentExecModel(m)
                conExecMsg=DAStudio.message('Simulink:BusElPorts:ActionWarnConcurrentExec',get_param(m,'Name'));
            end


            invalidNames=[];
            for i=1:numel(this.mData.signalNames)
                if~this.isValidElementString(this.mData.signalNames{i})
                    invalidNames(end+1)=i;%#ok<AGROW>
                end
            end
            sigNameMsg='';
            if~isempty(invalidNames)
                sigNameMsg=DAStudio.message('Simulink:BusElPorts:ActionWarnInvalidSignalName',this.joinCellStr(this.mData.signalNames(invalidNames),''', '''));
            end


            paramMsg=this.getParamWarningsIfNotSupported();


            cmsg={conExecMsg,paramMsg,sigNameMsg};
            cmsg=cmsg(~cellfun('isempty',cmsg));
            msg=this.joinCellStr(cmsg,'\n\n');
        end

        function msg=getParamWarningsIfNotSupported(this)
            msg='';
            cmsg={};
            bsh=this.mData.busSelector;
            blockName=this.getBlockNameForError(bsh);



            oab='OutputAsBus';
            oabDefVal='off';
            oabCurVal=get_param(bsh,oab);
            if~strcmp(oabCurVal,oabDefVal)
                cmsg=[cmsg,{DAStudio.message('Simulink:BusElPorts:ActionWarnBlockParam',oab,blockName,oabCurVal,oabDefVal)}];
            end

            ph=get_param(bsh,'PortHandles');
            badParams=Simulink.BlockDiagram.Internal.isPortDefault(ph.Inport,false);
            for i=1:numel(badParams)
                [param,curVal,defVal]=this.processNonDefaultParam(badParams{i},ph.Inport);
                tmpMsg=message('Simulink:BusElPorts:ActionWarnInputPortParam',param,1,blockName,curVal,defVal);
                cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
            end

            for i=1:numel(ph.Outport)
                badParams=Simulink.BlockDiagram.Internal.isPortDefault(ph.Outport(i),true);
                for j=1:numel(badParams)
                    [param,curVal,defVal]=this.processNonDefaultParam(badParams{j},ph.Outport(i));
                    tmpMsg=message('Simulink:BusElPorts:ActionWarnOutputPortParam',param,i,blockName,curVal,defVal);
                    cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
                end
            end


            for i=1:numel(this.mData.portBlocks)
                bh=this.mData.portBlocks(i);
                ph=get_param(bh,'PortHandles');
                ph=ph.Outport;
                blockName=this.getBlockNameForError(bh);

                isTopLevel=this.mData.editor.getDiagram().isTopLevel();
                isOutDTBusObject=startsWith(get_param(bh,'OutDataTypeStr'),'Bus: ');

                badParams=Simulink.BlockDiagram.Internal.isPortBlockDefault(bh);
                isComposite=strcmp(get_param(bh,'IsComposite'),'on');
                element=get_param(bh,'Element');
                this.mData.element=element;

                shouldSkipCheckingBadParams=false;
                elemNode=[];
                if(isComposite)
                    modeledPortBlk=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(bh);


                    port=modeledPortBlk.port;
                    tree=port.tree;
                    elemNode=Simulink.internal.CompositePorts.TreeNode.findNode(tree,element);

                    if~isempty(elemNode.busTypeElementAttrs)




                        shouldSkipCheckingBadParams=true;
                    end
                end

                for j=1:numel(badParams)

                    if shouldSkipCheckingBadParams
                        break;
                    end

                    thisParam=badParams{j};

                    if isComposite
                        [param,curVal,defVal,bepPropName,bepDefVal,bepCurVal]=this.processNonDefaultCompositePortParam(thisParam,bh,elemNode);
                    else
                        [param,curVal,defVal]=this.processNonDefaultParam(thisParam,bh);
                    end

                    if isOutDTBusObject

                        if strcmp(param,'BusOutputAsStruct')
                            this.mData.elemVirtuality=curVal;
                            continue;
                        end


                        if strcmp(param,'OutDataTypeStr')
                            this.mData.elemDataType=curVal;
                            continue;
                        end


                        if strcmp(param,'SampleTime')
                            this.mData.elemSampleTime=curVal;
                            continue;
                        end


                        if strcmp(param,'PortDimensions')&&strcmp(curVal,'1')
                            this.mData.elemDims=curVal;
                            continue;
                        end
                    end
                    if(isequal(curVal,defVal))
                        continue;
                    end

                    if isComposite
                        cmsg=[cmsg,{DAStudio.message('Simulink:BusElPorts:ActionWarnBlockParam',bepPropName,blockName,bepCurVal,bepDefVal)}];
                    else
                        cmsg=[cmsg,{DAStudio.message('Simulink:BusElPorts:ActionWarnBlockParam',param,blockName,curVal,defVal)}];
                    end
                end



                if isComposite
                    busVirtuality=get_param(bh,'BusVirtuality');
                    if(strcmp(busVirtuality,'nonvirtual')&&isTopLevel)
                        this.mData.elemVirtuality='on';
                    else
                        this.mData.elemVirtuality='off';
                    end
                end


                badParams=Simulink.BlockDiagram.Internal.isPortDefault(ph,false);
                for j=1:numel(badParams)
                    [param,curVal,defVal]=this.processNonDefaultParam(badParams{j},ph);
                    tmpMsg=message('Simulink:BusElPorts:ActionWarnOutputPortParam',param,1,blockName,curVal,defVal);
                    cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
                end
            end

            msg=this.processParameterWarningMsgs(DAStudio.message('Simulink:BusElPorts:ActionWarnParamPrefix'),cmsg);
        end

        function constructActionInfo(this)

            for i=1:numel(this.mData.signalNames)
                this.mData.signalNames{i}=this.appendElementString(this.mData.inportBlock,this.mData.signalNames{i});
            end

            bslh=get_param(this.mData.busSelector,'LineHandles');
            this.mData.lines=bslh.Outport;

            this.mData.newBlockPositions=cell(1,numel(bslh.Outport));
            for i=1:numel(bslh.Outport)
                this.mData.newBlockPositions{i}=computeNewBEIBlockPosition(this,this.mData.busSelector,i);
            end

            this.mData.orientations=repmat({get_param(this.mData.busSelector,'Orientation')},1,numel(bslh.Outport));


            siblings=this.mData.portBlocks(this.mData.portBlocks~=this.mData.inportBlock);
            for i=1:numel(siblings)

                this.mData.signalNames{end+1}='';

                slh=get_param(siblings(i),'LineHandles');
                this.mData.lines(end+1)=slh.Outport;

                this.mData.newBlockPositions{end+1}=computeNewBEIBlockPosition(this,siblings(i),1);

                this.mData.orientations{end+1}=get_param(siblings(i),'Orientation');
            end




            ilh=get_param(this.mData.inportBlock,'LineHandles');
            ilh=ilh.Outport;
            ilh=ilh(ilh~=bslh.Inport);
            if~isempty(ilh)
                this.mData.signalNames{end+1}=get_param(this.mData.inportBlock,'Element');
                this.mData.lines(end+1)=ilh;
                this.mData.newBlockPositions{end+1}=computeNewBEIBlockPosition(this,this.mData.inportBlock,1);

                this.mData.orientations{end+1}=get_param(this.mData.inportBlock,'Orientation');
            end


            this.mData.numElements=numel(this.mData.signalNames);
            assert(this.mData.numElements==(numel(bslh.Outport)+numel(siblings)+numel(ilh)));

            this.mData.newBlockHandles=ones(1,this.mData.numElements)*-1;
        end

        function makeConnections(this)
            for i=1:this.mData.numElements
                if ishandle(this.mData.lines(i))
                    l=SLM3I.SLDomain.handle2DiagramElement(this.mData.lines(i));

                    for j=1:l.terminator.size
                        if strcmpi(l.terminator.at(j).type,'In port')
                            term=l.terminator.at(j);
                            break;
                        end
                    end
                    port=get_param(this.mData.newBlockHandles(i),'PortHandles');
                    port=SLM3I.SLDomain.handle2DiagramElement(port.Outport);
                    SLM3I.SLDomain.createSegment(this.mData.editor,port,term);
                end
            end
        end

    end
end