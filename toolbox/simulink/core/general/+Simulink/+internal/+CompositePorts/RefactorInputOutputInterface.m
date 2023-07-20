classdef(Sealed)RefactorInputOutputInterface<Simulink.internal.CompositePorts.RefactorInterface


    methods(Access={?Simulink.internal.CompositePorts.RefactorInterfaceWrapper})

        function this=RefactorInputOutputInterface(editor,selection,actionData)
            narginchk(3,3);



            this@Simulink.internal.CompositePorts.RefactorInterface(editor,selection,mfilename('class'));


            this.mData=this.mixinStructs(this.mData,actionData);
        end
    end


    methods(Access=protected)
        function m=getEditorModels(this)
            srcDiag=SLM3I.SLDomain.handleToM3IModel(this.mData.srcSubsys);
            dstDiag=SLM3I.SLDomain.handleToM3IModel(this.mData.dstSubsys);
            m={this.mData.editor.getDiagram().model.getRootDeviant(),srcDiag.getRootDeviant(),dstDiag.getRootDeviant()};
        end
    end


    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        function tf=canExecuteImpl(this)

            tf=ishandle(this.mData.srcSubsys)&&...
            ishandle(this.mData.dstSubsys)&&...
            ~isempty(this.mData.lines)&&...
            all(ishandle(this.mData.lines));
        end


        function msg=executeImpl(this)

            msg='';



            [uniqueSrcPorts,dupFilter,signalIdx]=this.uniquify(this.mData.srcPorts);
            origOutportBlocks=this.getOutportBlocks(this.mData.srcSubsys,uniqueSrcPorts);
            origOutportBlocksWReps=this.getOutportBlocks(this.mData.srcSubsys,this.mData.srcPorts);



            dstPorts=str2double(get_param(this.mData.linesBySrc,'DstPort'))';
            origInportBlocks=this.getInportBlocks(this.mData.dstSubsys,dstPorts);

            signalNames=this.pickElements(this.mData.linesBySrc,origOutportBlocksWReps,origInportBlocks,signalIdx);

            origOutportBlockLines=this.forEachInArrayInCell(@this.getLineOfPortBlock,origOutportBlocks);
            origInportBlockLines=this.forEachInArrayInCell(@this.getLineOfPortBlock,origInportBlocks);

            newOutportBlockPos=this.forEachInArrayInCell(@(h)this.computeNewBEOBlockPosition(h,1),origOutportBlocks);
            newOutportBlockOrntn=this.makeRowCell(get_param([origOutportBlocks{:}],'Orientation'));
            newInportBlockPos=this.forEachInArrayInCell(@(h)this.computeNewBEIBlockPosition(h,1),origInportBlocks);
            newInportBlockOrntn=this.makeRowCell(get_param([origInportBlocks{:}],'Orientation'));



            linesToDelete=get_param(this.mData.srcSubsys,'LineHandles');
            linesToDelete=linesToDelete.Outport(uniqueSrcPorts);
            this.deleteLinesIncludingChildren(this.mData.editor,linesToDelete);

            if slsvTestingHook('BusActionsThrowBeforeChange')==1
                assert(false)
            end


            origOutportBlocks=[origOutportBlocks{:}];
            origInportBlocks=[origInportBlocks{:}];
            this.mData.modeledPortBlocks=[Simulink.BlockDiagram.Internal.getInterfaceModelBlock(origOutportBlocks(1)),...
            Simulink.BlockDiagram.Internal.getInterfaceModelBlock(origInportBlocks(1))];



            outportElements={signalNames.outportElements};
            outportElements=outportElements(dupFilter);
            newOutportBlocks=this.expandPortBlock(this.mData.editor,origOutportBlocks,'OutBus',[outportElements{:}],[newOutportBlockPos{:}],newOutportBlockOrntn);
            inportElements={signalNames.inportElements};
            newInportBlocks=this.expandPortBlock(this.mData.editor,origInportBlocks,'InBus',[inportElements{:}],[newInportBlockPos{:}],newInportBlockOrntn);




            [portsOutput,lineEndsOutput]=this.getBlockPortsAndLineEndsToConnect('output',newOutportBlocks,[origOutportBlockLines{:}]);
            [portsInput,lineEndsInput]=this.getBlockPortsAndLineEndsToConnect('input',newInportBlocks,[origInportBlockLines{:}]);
            this.connectBlockPortsAndLineEnds(portsOutput,lineEndsOutput);
            this.connectBlockPortsAndLineEnds(portsInput,lineEndsInput);
            this.connectSubsystems();

            if slsvTestingHook('BusActionsThrowAfterChange')==1
                assert(false)
            end
        end
    end


    methods(Access=private)
        function connectSubsystems(this)


            srcPortHandle=get_param(this.mData.srcSubsys,'PortHandles');
            srcPortHandle=srcPortHandle.Outport(this.mData.srcPorts(1));
            dstPortHandle=get_param(this.mData.dstSubsys,'PortHandles');
            dstPortHandle=dstPortHandle.Inport(this.mData.dstPorts(1));
            sp=SLM3I.SLDomain.handle2DiagramElement(srcPortHandle);
            dp=SLM3I.SLDomain.handle2DiagramElement(dstPortHandle);
            SLM3I.SLDomain.createSegment(this.mData.editor,sp,dp);


            dl=sp.edge.at(1);
            this.disconnectSegmentFromDst(dl);
            this.removeLabelsFromLine(dl.container);
            SLM3I.SLDomain.createSegment(this.mData.editor,dl.dstElement,dp);
        end
    end
end

