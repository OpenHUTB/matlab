classdef(Sealed)CleanupOutputInterface<Simulink.internal.CompositePorts.InterfaceAction


    methods(Access={?Simulink.internal.CompositePorts.CleanupInterfaceWrapper})

        function this=CleanupOutputInterface(editor,selection)
            narginchk(2,2);



            this@Simulink.internal.CompositePorts.InterfaceAction(editor,selection,mfilename('class'));


            this.mData.busCreator=-1;
            this.mData.dstBlock=-1;
            this.mData.outportBlock=-1;

            pickBusCreator(this);

            pickOutport(this);
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
            isUnderStateflowBlock=~isTopLevel&&this.isStateflowBlock(get_param(get_param(this.mData.outportBlock,'Parent'),'Parent'));
            isForEachSubsystem=~isTopLevel&&Simulink.BlockDiagram.Internal.isForEachSubsystem(get_param(get_param(this.mData.outportBlock,'Parent'),'Handle'));
            tf=ishandle(this.mData.busCreator)&&...
            ishandle(this.mData.outportBlock)&&...
            ~isUnderStateflowBlock&&...
            ~isForEachSubsystem;
        end


        function msg=executeImpl(this)


            msg=this.getWarningsIfNotSupported();
            if~isempty(msg)
                return;
            end


            this.constructActionInfo();


            lh=get_param(this.mData.busCreator,'LineHandles');
            this.deleteDiagramElement(this.mData.editor,lh.Outport);

            if slsvTestingHook('BusActionsThrowBeforeChange')==1
                assert(false)
            end


            this.mData.modeledPortBlocks=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(this.mData.outportBlock);


            this.mData.newBlockHandles=this.expandPortBlock(this.mData.editor,[this.mData.outportBlock,this.mData.busCreator],'',this.mData.signalNames,this.mData.newBlockPositions,this.mData.orientations);


            this.makeConnections();


            this.mData.editor.clearSelection();


            for i=this.mData.numElements:-1:1
                this.mData.editor.select(SLM3I.SLDomain.handle2DiagramElement(this.mData.newBlockHandles(i)));
            end





            interfaceBlock=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(this.mData.newBlockHandles(1));


            port=interfaceBlock.port;
            tree=port.tree;

            element=this.mData.element;

            isRoot=isempty(element);

            if(isRoot)

                elemNode=Simulink.internal.CompositePorts.TreeNode.findNode(tree,element);
                if(isfield(this.mData,'elemDataType'))
                    elemDataType=this.mData.elemDataType;
                else
                    elemDataType='Inherit: auto';
                end
                Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(elemNode,elemDataType);

                if(startsWith(elemDataType,'Bus: '))
                    if(isfield(this.mData,'elemVirtuality')&&strcmpi(this.mData.elemVirtuality,'on'))

                        Simulink.internal.CompositePorts.TreeNode.setVirtualityCL(elemNode,...
                        sl.mfzero.treeNode.Virtuality.NON_VIRTUAL);
                        if(isfield(this.mData,'elemSampleTime'))
                            elemSampleTime=this.mData.elemSampleTime;
                            Simulink.internal.CompositePorts.TreeNode.setSampleTimeCL(elemNode,elemSampleTime);
                        end

                        if(isfield(this.mData,'elemDims')&&strcmpi(this.mData.elemDims,'1'))
                            Simulink.internal.CompositePorts.TreeNode.setDimsCL(elemNode,this.mData.elemDims);
                        end
                    else
                        Simulink.internal.CompositePorts.TreeNode.setVirtualityCL(elemNode,...
                        sl.mfzero.treeNode.Virtuality.INHERIT);
                    end
                end
            end

            if slsvTestingHook('BusActionsThrowAfterChange')==1
                assert(false)
            end
        end
    end


    methods(Access=private)

        function pickBusCreator(this)

            h=this.getBlocksOfType(this.mData.selection,'BusCreator');

            if isempty(h)||numel(h)~=1
                return;
            end


            dst=this.getDstBlocks(h);
            dst=dst{1};
            isOutportBlock=arrayfun(@(h)ishandle(h)&&strcmpi(get_param(h,'type'),'block')&&strcmpi(get_param(h,'BlockType'),'Outport'),dst);
            if~any(isOutportBlock)
                return;
            end


            dst=dst(isOutportBlock);
            this.mData.dstBlock=dst(1);


            this.mData.busCreator=h;
        end


        function pickOutport(this)

            if~ishandle(this.mData.busCreator)||~ishandle(this.mData.dstBlock)
                return;
            end


            this.mData.outportBlock=this.mData.dstBlock;
        end

        function msg=getWarningsIfNotSupported(this)
            msg='';


            conExecMsg='';
            m=bdroot(this.mData.busCreator);
            if this.isConcurrentExecModel(m)
                conExecMsg=DAStudio.message('Simulink:BusElPorts:ActionWarnConcurrentExec',get_param(m,'Name'));
            end


            dst=this.getDstBlocks(this.mData.busCreator);
            dst=dst{1};
            branchMsg='';
            if numel(dst)~=1||~ishandle(dst)||~strcmpi(get_param(dst,'type'),'block')||~strcmpi(get_param(dst,'BlockType'),'Outport')
                branchMsg=DAStudio.message('Simulink:BusElPorts:ActionWarnBusCreatorBranch');
            end


            paramMsg=this.getParamWarningsIfNotSupported();


            cmsg={conExecMsg,branchMsg,paramMsg};
            cmsg=cmsg(~cellfun('isempty',cmsg));
            msg=this.joinCellStr(cmsg,'\n\n');
        end

        function msg=getParamWarningsIfNotSupported(this)
            msg='';
            cmsg={};
            bch=this.mData.busCreator;
            bcName=this.getBlockNameForError(bch);


            odts='OutDataTypeStr';
            odtsDefVal='Inherit: auto';
            odtsCurVal=get_param(bch,odts);
            isbcOutDTDefault=strcmp(odtsCurVal,odtsDefVal);

            obcvirtuality=get_param(bch,'NonVirtualBus');
            isBcOutputNvb=false;
            if~isbcOutDTDefault&&strcmp(obcvirtuality,'on')
                isBcOutputNvb=true;
            end

            isTopLevel=this.mData.editor.getDiagram().isTopLevel();
            mis='MatchInputsString';
            misDefVal='off';
            misCurVal=get_param(bch,mis);
            if~strcmp(misCurVal,misDefVal)
                cmsg=[cmsg,{DAStudio.message('Simulink:BusElPorts:ActionWarnBlockParam',mis,bcName,misCurVal,misDefVal)}];
            end


            ph=get_param(bch,'PortHandles');
            for i=1:numel(ph.Inport)

                badParams=Simulink.BlockDiagram.Internal.isPortDefault(ph.Inport(i),true);
                for j=1:numel(badParams)
                    [param,curVal,defVal]=this.processNonDefaultParam(badParams{j},ph.Inport(i));
                    tmpMsg=message('Simulink:BusElPorts:ActionWarnInputPortParam',param,i,bcName,curVal,defVal);
                    cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
                end
            end
            badParams=Simulink.BlockDiagram.Internal.isPortDefault(ph.Outport,false);
            for i=1:numel(badParams)
                [param,curVal,defVal]=this.processNonDefaultParam(badParams{i},ph.Outport);
                tmpMsg=message('Simulink:BusElPorts:ActionWarnOutputPortParam',param,1,bcName,curVal,defVal);
                cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
            end


            pbh=this.mData.outportBlock;
            ph=get_param(pbh,'PortHandles');
            ph=ph.Inport;
            pbName=this.getBlockNameForError(pbh);

            badParams=Simulink.BlockDiagram.Internal.isPortBlockDefault(pbh);
            isComposite=strcmp(get_param(pbh,'IsComposite'),'on');
            element=get_param(pbh,'Element');
            this.mData.element=element;

            isConversionPossible=true;
            if(isComposite)
                modeledPortBlk=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(pbh);



                port=modeledPortBlk.port;
                tree=port.tree;

                isRootNode=isempty(element);


                if~isRootNode&&~isempty(badParams)
                    isConversionPossible=false;
                end
                elemNode=Simulink.internal.CompositePorts.TreeNode.findNode(tree,element);
                bepdt=Simulink.internal.CompositePorts.TreeNode.getDataType(elemNode);
                isOutDTBusObject=startsWith(bepdt,'Bus: ');
                if isRootNode
                    elemVirtuality=Simulink.internal.CompositePorts.TreeNode.getVirtuality(elemNode);
                    if isequal(elemVirtuality,sl.mfzero.treeNode.Virtuality.NON_VIRTUAL)
                        this.mData.elemVirtuality='on';
                    else
                        this.mData.elemVirtuality='off';
                    end
                end

                if isConversionPossible



                    isDefaultDT=strcmp('Inherit: auto',bepdt);

                    if~isbcOutDTDefault&&~isDefaultDT&&~strcmp(odtsCurVal,bepdt)
                        tmpMsg=message('Simulink:BusElPorts:ActionWarnBusCreatorBEPDTMismatch',...
                        bcName,odtsCurVal,pbName,bepdt);
                        cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
                    end
                end
            else

                elemNode=[];
                outDT=get_param(pbh,'OutDataTypeStr');
                isOutDTBusObject=startsWith(outDT,'Bus: ');
                isOutDTDefault=strcmp(outDT,'Inherit: auto');



                if(~isbcOutDTDefault&&~isOutDTDefault&&~strcmp(odtsCurVal,outDT))
                    tmpMsg=message('Simulink:BusElPorts:ActionWarnBusCreatorBEPDTMismatch',...
                    bcName,odtsCurVal,pbName,outDT);
                    cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
                end
            end

            for i=1:numel(badParams)

                thisParam=badParams{i};

                if isComposite
                    [param,curVal,defVal,bepPropName,bepDefVal,bepCurVal]=this.processNonDefaultCompositePortParam(thisParam,pbh,elemNode);
                else
                    [param,curVal,defVal]=this.processNonDefaultParam(thisParam,pbh);
                end

                if isConversionPossible&&isOutDTBusObject

                    if(strcmp(param,'BusOutputAsStruct'))
                        this.mData.elemVirtuality=curVal;
                        continue;
                    end


                    if(strcmp(param,'OutDataTypeStr'))
                        this.mData.elemDataType=curVal;
                        continue;
                    end


                    if(strcmp(param,'SampleTime'))
                        this.mData.elemSampleTime=curVal;
                        continue;
                    end


                    if(strcmp(param,'PortDimensions')&&strcmp(curVal,'1'))
                        this.mData.elemDims=curVal;
                        continue;
                    end
                end

                if(isequal(curVal,defVal))
                    continue;
                end

                if isComposite
                    cmsg=[cmsg,{DAStudio.message('Simulink:BusElPorts:ActionWarnBlockParam',bepPropName,pbName,bepCurVal,bepDefVal)}];
                else
                    cmsg=[cmsg,{DAStudio.message('Simulink:BusElPorts:ActionWarnBlockParam',param,pbName,curVal,defVal)}];
                end
            end


            if isConversionPossible


                if~isfield(this.mData,'elemDataType')
                    this.mData.elemDataType=odtsCurVal;
                end



                if isTopLevel&&isComposite&&isBcOutputNvb&&...
                    (~isfield(this.mData,'elemVirtuality')||...
                    strcmp(this.mData.elemVirtuality,'off'))
                    this.mData.elemVirtuality='on';
                end
            end


            badParams=Simulink.BlockDiagram.Internal.isPortDefault(ph,false);
            for i=1:numel(badParams)
                [param,curVal,defVal]=this.processNonDefaultParam(badParams{i},ph);
                tmpMsg=message('Simulink:BusElPorts:ActionWarnInputPortParam',param,1,pbName,curVal,defVal);
                cmsg=[cmsg,{MSLDiagnostic(tmpMsg).message}];
            end

            msg=this.processParameterWarningMsgs(DAStudio.message('Simulink:BusElPorts:ActionWarnParamPrefix'),cmsg);
        end

        function constructActionInfo(this)

            warnState=warning;
            cleanupObj=onCleanup(@()warning(warnState));
            warning('off');

            this.mData.numElements=str2double(get_param(this.mData.busCreator,'Inputs'));

            lh=get_param(this.mData.busCreator,'LineHandles');
            this.mData.lines=lh.Inport;
            try


                blockObject=get_param(this.mData.busCreator,'Object');
                this.mData.signalNames={blockObject.SignalHierarchy.name};
            catch

                this.mData.signalNames=arrayfun(@(x)sprintf('signal%d',x),...
                1:this.mData.numElements,'UniformOutput',false);
            end

            this.mData.newBlockPositions=cell(1,this.mData.numElements);
            for i=1:this.mData.numElements
                this.mData.newBlockPositions{i}=this.computeNewBEOBlockPosition(this.mData.busCreator,i);
                assert(~isempty(this.mData.signalNames{i}));

                this.mData.signalNames{i}=this.appendElementString(this.mData.outportBlock,this.mData.signalNames{i});
            end
            this.mData.newBlockHandles=ones(1,this.mData.numElements)*-1;

            this.mData.orientations=repmat({get_param(this.mData.busCreator,'Orientation')},1,this.mData.numElements);
        end

        function makeConnections(this)
            for i=1:this.mData.numElements
                if ishandle(this.mData.lines(i))
                    l=SLM3I.SLDomain.handle2DiagramElement(this.mData.lines(i));





                    if l.container.segment.size==1
                        srcPort=get_param(this.mData.lines(i),'SrcPortHandle');
                        if~ishandle(srcPort)||isempty(Simulink.BlockDiagram.Internal.isPortDefault(srcPort,true))
                            this.removeLabelsFromLine(l.container);
                        end
                    end

                    for j=1:l.terminator.size
                        if strcmpi(l.terminator.at(j).type,'Out port')
                            term=l.terminator.at(j);
                            break;
                        end
                    end
                    port=get_param(this.mData.newBlockHandles(i),'PortHandles');
                    port=SLM3I.SLDomain.handle2DiagramElement(port.Inport);
                    SLM3I.SLDomain.createSegment(this.mData.editor,term,port);
                end
            end
        end
    end
end
