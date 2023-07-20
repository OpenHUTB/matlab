classdef(Sealed)RefactorOutputInterface<Simulink.internal.CompositePorts.RefactorInterface


    methods(Access={?Simulink.internal.CompositePorts.RefactorInterfaceWrapper})

        function this=RefactorOutputInterface(editor,selection,actionData)
            narginchk(3,3);



            this@Simulink.internal.CompositePorts.RefactorInterface(editor,selection,mfilename('class'));


            this.mData=this.mixinStructs(this.mData,actionData);
        end
    end


    methods(Access=protected)
        function m=getEditorModels(this)
            diag=SLM3I.SLDomain.handleToM3IModel(this.mData.srcSubsys);
            m={this.mData.editor.getDiagram().model.getRootDeviant(),diag.getRootDeviant()};
        end
    end


    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})


        function tf=canExecuteImpl(this)

            tf=ishandle(this.mData.srcSubsys)&&...
            ~isempty(this.mData.linesBySrc)&&...
            all(ishandle(this.mData.linesBySrc));
        end


        function msg=executeImpl(this)

            msg='';



            this.mData.srcPorts=unique(this.mData.srcPorts);
            origOutportBlocks=this.getOutportBlocks(this.mData.srcSubsys,this.mData.srcPorts);


            lh=get_param(this.mData.srcSubsys,'LineHandles');
            this.mData.linesBySrc=lh.Outport(this.mData.srcPorts);

            signalIdx=1:numel(this.mData.srcPorts);

            emptyCellArray=cell(1,numel(this.mData.srcPorts));
            this.mData.signalNames=this.pickElements(this.mData.linesBySrc,origOutportBlocks,emptyCellArray,signalIdx);

            lh=get_param(this.mData.srcSubsys,'LineHandles');
            this.mData.linesBySrc=lh.Outport(this.mData.srcPorts);

            origOutportBlockLines=this.forEachInArrayInCell(@this.getLineOfPortBlock,origOutportBlocks);

            this.computeBusSelectorPosAndOrntn();

            newPortBlockPos=this.forEachInArrayInCell(@(h)this.computeNewBEOBlockPosition(h,1),origOutportBlocks);
            newPortBlockOrntn=this.makeRowCell(get_param([origOutportBlocks{:}],'Orientation'));


            this.mData.busSelector=this.addBusSelector();

            this.connectBusSelectorOutputs();

            if slsvTestingHook('BusActionsThrowBeforeChange')==1
                assert(false)
            end


            origOutportBlocks=[origOutportBlocks{:}];
            this.mData.modeledPortBlocks=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(origOutportBlocks(1));


            elements={this.mData.signalNames.outportElements};
            newPortBlocks=this.expandPortBlock(this.mData.editor,origOutportBlocks,'OutBus',[elements{:}],[newPortBlockPos{:}],newPortBlockOrntn);

            [ports,lineEnds]=this.getBlockPortsAndLineEndsToConnect('output',newPortBlocks,[origOutportBlockLines{:}]);
            this.connectBlockPortsAndLineEnds(ports,lineEnds);


            this.connectBusSelectorInput();

            if slsvTestingHook('BusActionsThrowAfterChange')==1
                assert(false)
            end
        end
    end



    methods(Access=private)

        function computeBusSelectorPosAndOrntn(this)

            this.mData.busSelectorOrntn=get_param(this.mData.srcSubsys,'Orientation');
            ph=get_param(this.mData.srcSubsys,'PortHandles');
            ph=ph.Outport;
            numPorts=numel(this.mData.srcPorts);
            firstPortPos=get_param(ph(this.mData.srcPorts(1)),'Position');
            lastPortPos=get_param(ph(this.mData.srcPorts(end)),'Position');
            ratio=numPorts/(numPorts-1);

            switch this.mData.busSelectorOrntn
            case{'left','right'}
                heightHalf=abs(lastPortPos(2)-firstPortPos(2))*ratio/2;
            case{'up','down'}
                heightHalf=abs(lastPortPos(1)-firstPortPos(1))*ratio/2;
            end

            midX=mean([firstPortPos(1),lastPortPos(1)]);
            midY=mean([firstPortPos(2),lastPortPos(2)]);

            offset=40;
            blockWidth=5;



            pos=[midX+offset,midY-heightHalf,midX+blockWidth+offset,midY+heightHalf];
            switch this.mData.busSelectorOrntn
            case 'left'
                pos=[midX-blockWidth-offset,midY-heightHalf,midX-offset,midY+heightHalf];
            case 'up'
                pos=[midX-heightHalf,midY-blockWidth-offset,midX+heightHalf,midY-offset];
            case 'down'
                pos=[midX-heightHalf,midY+offset,midX+heightHalf,midY+blockWidth+offset];
            end


            this.mData.busSelectorPos=this.clipPos(pos);
        end

        function h=addBusSelector(this)
            h=private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
            'add_block','simulink/Signal Routing/Bus Selector',...
            [this.mData.editor.getName,'/Bus Selector'],'MakeNameUnique','on');

            private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
            'set_param',h,'Orientation',this.mData.busSelectorOrntn,...
            'OutputSignals',strjoin({this.mData.signalNames.name},','),...
            'Position',this.mData.busSelectorPos);
        end

        function connectBusSelectorOutputs(this)
            bsph=get_param(this.mData.busSelector,'PortHandles');
            bsph=bsph.Outport;

            for i=1:numel(this.mData.linesBySrc)
                dl=SLM3I.SLDomain.handle2DiagramElement(this.mData.linesBySrc(i));

                this.disconnectSegmentFromSrc(dl);


                this.removeLabelsFromLine(dl.container);

                SLM3I.SLDomain.createSegment(this.mData.editor,SLM3I.SLDomain.handle2DiagramElement(bsph(i)),dl.srcElement);
            end
        end

        function connectBusSelectorInput(this)

            bsp=get_param(this.mData.busSelector,'PortHandles');
            bsp=bsp.Inport;
            bsp=SLM3I.SLDomain.handle2DiagramElement(bsp);

            ssp=get_param(this.mData.srcSubsys,'PortHandles');
            ssp=ssp.Outport(this.mData.srcPorts(1));
            ssp=SLM3I.SLDomain.handle2DiagramElement(ssp);

            SLM3I.SLDomain.createSegment(this.mData.editor,ssp,bsp);

            l=get_param(this.mData.srcSubsys,'LineHandles');
            l=l.Outport(this.mData.srcPorts(1));
            this.removeLabelsFromLine(SLM3I.SLDomain.handle2DiagramElement(l).container);
        end


    end

end


