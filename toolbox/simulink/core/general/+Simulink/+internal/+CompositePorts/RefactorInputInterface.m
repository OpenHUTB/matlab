classdef(Sealed)RefactorInputInterface<Simulink.internal.CompositePorts.RefactorInterface


    methods(Access={?Simulink.internal.CompositePorts.RefactorInterfaceWrapper})

        function this=RefactorInputInterface(editor,selection,actionData)
            narginchk(3,3);



            this@Simulink.internal.CompositePorts.RefactorInterface(editor,selection,mfilename('class'));


            this.mData=this.mixinStructs(this.mData,actionData);
        end
    end


    methods(Access=protected)
        function m=getEditorModels(this)
            diag=SLM3I.SLDomain.handleToM3IModel(this.mData.dstSubsys);
            m={this.mData.editor.getDiagram().model.getRootDeviant(),diag.getRootDeviant()};
        end
    end


    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        function tf=canExecuteImpl(this)

            tf=ishandle(this.mData.dstSubsys)&&...
            ~isempty(this.mData.linesByDst)&&...
            all(ishandle(this.mData.linesByDst));
        end


        function msg=executeImpl(this)

            msg='';





            srcPortHandles=get_param(this.mData.linesByDst,'SrcPortHandle');
            srcPortHandles=[srcPortHandles{:}];

            [this.mData.srcPortHandles,dupFilter,signalIdx]=this.uniquify(srcPortHandles);

            this.mData.dstPortHandles=get_param(this.mData.linesByDst,'DstPortHandle');
            this.mData.dstPortHandles=[this.mData.dstPortHandles{:}];

            origInportBlocks=this.getInportBlocks(this.mData.dstSubsys,this.mData.dstPorts);

            emptyCellArray=cell(1,numel(this.mData.linesByDst));
            this.mData.signalNames=this.pickElements(this.mData.linesByDst,emptyCellArray,origInportBlocks,signalIdx);

            origInportBlockLines=this.forEachInArrayInCell(@this.getLineOfPortBlock,origInportBlocks);

            newPortBlockPos=this.forEachInArrayInCell(@(h)this.computeNewBEIBlockPosition(h,1),origInportBlocks);
            newPortBlockOrntn=this.makeRowCell(get_param([origInportBlocks{:}],'Orientation'));

            this.computeBusCreatorPosAndOrntn();


            linesToDelete=get_param(this.mData.srcPortHandles,'Line');
            this.deleteLinesIncludingChildren(this.mData.editor,[linesToDelete{:}]);

            if slsvTestingHook('BusActionsThrowBeforeChange')==1
                assert(false)
            end


            origInportBlocks=[origInportBlocks{:}];
            this.mData.modeledPortBlocks=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(origInportBlocks(1));


            elements={this.mData.signalNames.inportElements};
            newPortBlocks=this.expandPortBlock(this.mData.editor,origInportBlocks,'InBus',[elements{:}],[newPortBlockPos{:}],newPortBlockOrntn);

            [ports,lineEnds]=this.getBlockPortsAndLineEndsToConnect('input',newPortBlocks,[origInportBlockLines{:}]);
            this.connectBlockPortsAndLineEnds(ports,lineEnds);


            this.mData.signalNames=this.mData.signalNames(dupFilter);
            this.mData.busCreator=this.addBusCreator(this.mData.editor.getName,this.mData.busCreatorOrntn,numel(this.mData.srcPortHandles),this.mData.busCreatorPos);

            this.connectBusCreatorInputs();
            this.connectBusCreatorOutput();

            if slsvTestingHook('BusActionsThrowAfterChange')==1
                assert(false)
            end
        end
    end


    methods(Access=private)
        function computeBusCreatorPosAndOrntn(this)

            numPorts=numel(this.mData.srcPortHandles);

            this.mData.busCreatorOrntn=get_param(this.mData.dstSubsys,'Orientation');
            firstPortPos=get_param(this.mData.dstPortHandles(1),'Position');
            lastPortPos=get_param(this.mData.dstPortHandles(end),'Position');
            ratio=numPorts/(numPorts-1);

            switch this.mData.busCreatorOrntn
            case{'left','right'}
                heightHalf=abs(lastPortPos(2)-firstPortPos(2))*ratio/2;
            case{'up','down'}
                heightHalf=abs(lastPortPos(1)-firstPortPos(1))*ratio/2;
            end

            midX=mean([firstPortPos(1),lastPortPos(1)]);
            midY=mean([firstPortPos(2),lastPortPos(2)]);

            offset=40;
            blockWidth=5;



            pos=[midX-blockWidth-offset,midY-heightHalf,midX-offset,midY+heightHalf];
            switch this.mData.busCreatorOrntn
            case 'left'
                pos=[midX+offset,midY-heightHalf,midX+blockWidth+offset,midY+heightHalf];
            case 'up'
                pos=[midX-heightHalf,midY+offset,midX+heightHalf,midY+blockWidth+offset];
            case 'down'
                pos=[midX-heightHalf,midY-blockWidth-offset,midX+heightHalf,midY-offset];
            end


            this.mData.busCreatorPos=this.clipPos(pos);
        end

        function connectBusCreatorInputs(this)
            bcph=get_param(this.mData.busCreator,'PortHandles');
            bcph=bcph.Inport;

            for i=1:numel(this.mData.srcPortHandles)


                sp=SLM3I.SLDomain.handle2DiagramElement(this.mData.srcPortHandles(i));
                dp=SLM3I.SLDomain.handle2DiagramElement(bcph(i));


                SLM3I.SLDomain.createSegment(this.mData.editor,sp,dp);



                if this.mData.signalNames(i).setOnLine
                    dl=sp.edge.at(1);
                    this.disconnectSegmentFromDst(dl);
                    this.addLabelToSegment(dl,this.mData.signalNames(i).name);
                    SLM3I.SLDomain.createSegment(this.mData.editor,dl.dstElement,dp);
                end
            end
        end

        function connectBusCreatorOutput(this)

            bcp=get_param(this.mData.busCreator,'PortHandles');
            bcp=bcp.Outport;
            bcp=SLM3I.SLDomain.handle2DiagramElement(bcp);

            ssp=get_param(this.mData.dstSubsys,'PortHandles');
            ssp=ssp.Inport(this.mData.dstPorts(1));
            ssp=SLM3I.SLDomain.handle2DiagramElement(ssp);

            SLM3I.SLDomain.createSegment(this.mData.editor,bcp,ssp);
        end

    end

end


