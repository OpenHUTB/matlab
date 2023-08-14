
classdef ExpandVirtualBusPortsForModelBlocks<Simulink.ModelReference.Conversion.AutoFix



    properties(Transient,SetAccess=private,GetAccess=public)
        Results;
    end

    properties(Transient,SetAccess=private,GetAccess=private)
ConversionData
ConversionParameters
Systems
Parents
NewSystems
CompiledIOInfos
CompiledBus
DataSource
CreatedBusObjects
        Inports=[]
        Outports=[]
        AddLineOpts={'autorouting','on'};
    end

    properties(Transient,SetAccess=private,GetAccess=private)
PortWidth
PortHeight
        ModelBlocks=[]


OriginalWrapperSubsystemInports
OriginalModelBlockInports
OriginalNewModelInports

OriginalWrapperSubsystemOutports
OriginalModelBlockOutports
OriginalNewModelOutports
    end

    properties(Constant,Access=public)
        FindOptions={'SearchDepth',1,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on'}
        SepChar='.';
    end

    methods(Access=public)
        function this=ExpandVirtualBusPortsForModelBlocks(param,ioInfos,busNames,modelBlocks)
            this.IsModifiedSystemInterface=true;
            this.ConversionData=param;
            this.ConversionParameters=param.ConversionParameters;
            this.Systems=this.ConversionParameters.Systems;
            this.ModelBlocks=modelBlocks;
            this.Parents=arrayfun(@(ss)get_param(get_param(ss,'Parent'),'Handle'),this.Systems);
            this.DataSource=param.DataAccessor;
            this.CreatedBusObjects=Simulink.ModelReference.Conversion.CreatedBusObjects(this.DataSource,busNames);
            this.CompiledIOInfos=ioInfos;
            [this.PortWidth,this.PortHeight]=Simulink.ModelReference.Conversion.Utilities.computePortSize(this.Systems(1));
            this.AddLineOpts=Simulink.ModelReference.Conversion.BusExpansionBlock.AddLineOpts;
        end

        function fix(this)
            numberOfSystems=numel(this.Systems);
            for idx=1:numberOfSystems
                subsys=this.Systems(idx);
                newModelName=this.ConversionParameters.ModelReferenceNames{idx};
                newModel=get_param(newModelName,'Handle');
                aModelBlock=this.ModelBlocks(idx);
                parent=get_param(get_param(aModelBlock,'Parent'),'Handle');





                blks=find_system(newModel,'SearchDepth',1);
                graphicalInfo=Simulink.ModelReference.Conversion.CopyGraphicalInfo.create(subsys);
                ssObj=get_param(newModel,'Object');
                ssObj.localCreateSubSystem(blks(2:end));
                newSubsystem=find_system(newModel,'LookUnderMasks','all','SearchDepth',1,'BlockType','SubSystem');
                graphicalInfo.copy(newSubsystem);
                newSubsystemPortHandles=get_param(newSubsystem,'PortHandles');
                newSubsystemInports=find_system(newSubsystem,'LookUnderMasks','all','SearchDepth',1,'BlockType','Inport');
                newSubsystemOutports=find_system(newSubsystem,'LookUnderMasks','all','SearchDepth',1,'BlockType','Outport');


                compInfo=this.CompiledIOInfos{idx};
                this.OriginalNewModelInports=find_system(newModel,'SearchDepth',1,'BlockType','Inport');
                this.OriginalNewModelOutports=find_system(newModel,'SearchDepth',1,'BlockType','Outport');
                ioPorts=vertcat(this.OriginalNewModelInports,this.OriginalNewModelOutports);
                N=numel(compInfo);




                this.OriginalWrapperSubsystemInports=find_system(parent,'SearchDepth',1,'BlockType','Inport');
                this.OriginalWrapperSubsystemOutports=find_system(parent,'SearchDepth',1,'BlockType','Outport');



                modelBlockPortHandles=get_param(aModelBlock,'PortHandles');
                arrayfun(@(aPort)delete(get_param(aPort,'Line')),modelBlockPortHandles.Inport);
                arrayfun(@(aPort)delete(get_param(aPort,'Line')),modelBlockPortHandles.Outport);

                parentBusCreator=[];
                parentBusSelector=[];

                childBusCreator=[];
                childBusSelector=[];


                disconnectedInports=[];
                disconnectedOutports=[];
                for portIdx=1:N
                    portInfo=compInfo(portIdx);
                    busName=portInfo.busName;




                    aMask=strcmp(this.CreatedBusObjects.BusNames,busName);
                    aPort=ioPorts(portIdx);
                    if any(aMask)
                        busObject=this.CreatedBusObjects.BusObjects{aMask};
                        if strcmp(get_param(portInfo.block,'BlockType'),'Inport')
                            this.resetInportAttributes(aPort,newSubsystemPortHandles,newSubsystemInports);
                            [parentBusSelector(end+1),childBusCreator(end+1)]=...
                            this.expandInport(aModelBlock,newModel,parent,aPort,busObject,busName);%#ok
                        else
                            this.resetOutportAttributes(aPort,newSubsystemPortHandles,newSubsystemOutports);
                            [parentBusCreator(end+1),childBusSelector(end+1)]=...
                            this.expandOutport(aModelBlock,newModel,parent,aPort,busObject,busName);%#ok
                        end
                    else
                        if strcmp(get_param(portInfo.block,'BlockType'),'Inport')
                            disconnectedInports(end+1)=aPort;%#ok
                        else
                            disconnectedOutports(end+1)=aPort;%#ok
                        end
                    end
                end


                this.reconnectInports(parent,aModelBlock,newModel,disconnectedInports);
                this.reconnectOutports(parent,aModelBlock,newModel,disconnectedOutports);
            end
        end

        function results=getActionDescription(this)
            results=this.Results;
        end
    end

    methods(Access=private)


        function blk=createSystem(this,bdObj,subsys)
            blks=find_system(subsys,this.FindOptions{:});
            annotations=find_system(subsys,this.FindOptions{:},'Type','annotation');
            bdObj.localCreateSubSystem(vertcat(blks(2:end),annotations));
            blk=get_param(get_param(blks(1),'Parent'),'Handle');
        end


        function[parentBusSelector,childBusCreator]=expandInport(this,aModelBlock,newModel,parent,currentInport,busObject,busName)
            newModelInports=find_system(newModel,'SearchDepth',1,'BlockType','Inport');
            inportMask=(newModelInports==currentInport);


            pos=get_param(currentInport,'Position');
            portHeight=pos(4)-pos(2);


            busCreator=Simulink.ModelReference.Conversion.BusCreator(this.CreatedBusObjects,newModel,busObject);


            aModelBlockObj=get_param(aModelBlock,'Object');
            inportNames=busCreator.InportNames;






            baseName=get_param(currentInport,'Name');
            set_param(currentInport,'Name',sprintf('%s%s%s',baseName,this.SepChar,inportNames{1}));
            this.updatePortAttributes(currentInport,busCreator.PortAttributes{1});

            numberOfNewPorts=numel(inportNames);
            inports=zeros(numberOfNewPorts,1);
            inportDistance=portHeight*2;


            inports(1)=currentInport;
            portHandles=get_param(currentInport,'PortHandles');
            oPort=portHandles.Outport(1);
            aLine=get_param(oPort,'Line');
            srcPort=get_param(aLine,'SrcPortHandle');
            dstBlocks=get_param(aLine,'DstBlockHandle');
            dstPorts=get_param(aLine,'DstPortHandle');


            this.adjustBlkPosition(currentInport,busCreator,dstBlocks(1),...
            pos(2)+((numberOfNewPorts-1/2)*inportDistance-busCreator.BlkHeight)/2);



            delete(aLine);
            add_line(newModel,srcPort,busCreator.PortHandles.Inport(1),this.AddLineOpts{:});


            lines=arrayfun(@(dstPort)add_line(newModel,busCreator.PortHandles.Outport(1),dstPort,this.AddLineOpts{:}),dstPorts);
            set_param(lines(1),'Name',busName);


            newModelName=get_param(newModel,'Name');
            currentInportNumber=find(inportMask);
            for newPortIdx=2:numberOfNewPorts
                aPort=add_block('built-in/Inport',...
                sprintf('%s/%s%s%s',newModelName,baseName,this.SepChar,inportNames{newPortIdx}),'MakeNameUnique','on');


                yshift=(newPortIdx-1)*inportDistance;
                newPos=[pos(1),pos(2)+yshift,pos(3),pos(4)+yshift];
                set_param(aPort,'Position',newPos);
                set(aPort,'Port',num2str(currentInportNumber+newPortIdx-1));
                inports(newPortIdx)=aPort;


                ph=get_param(aPort,'PortHandles');
                add_line(newModel,ph.Outport(1),busCreator.PortHandles.Inport(newPortIdx),this.AddLineOpts{:});


                this.updatePortAttributes(aPort,busCreator.PortAttributes{newPortIdx});
            end



            aModelBlockObj.refreshModelBlock;
            modelBlockPortHandles=get_param(aModelBlock,'PortHandles');
            modelBlockInports=modelBlockPortHandles.Inport(currentInportNumber:currentInportNumber+numberOfNewPorts-1);


            busSelector=Simulink.ModelReference.Conversion.BusSelector(this.CreatedBusObjects,parent,busObject);



            aMask=this.OriginalNewModelInports==currentInport;
            srcBlock=this.OriginalWrapperSubsystemInports(aMask);
            pos=get_param(srcBlock,'Position');
            assert(~isempty(srcBlock));
            portHeight=pos(4)-pos(2);
            ypos=pos(2)-(busSelector.BlkHeight-portHeight)/2;
            this.adjustBlkPosition(srcBlock,busSelector,aModelBlock,ypos);


            for idx=1:numel(modelBlockInports)
                add_line(parent,busSelector.PortHandles.Outport(idx),modelBlockInports(idx),this.AddLineOpts{:});
            end

            inportHandles=get_param(srcBlock,'PortHandles');
            add_line(parent,inportHandles.Outport,busSelector.PortHandles.Inport,this.AddLineOpts{:});


            parentBusSelector=busSelector.System;
            childBusCreator=busCreator.System;
        end


        function[parentBusCreator,childBusSelector]=expandOutport(this,aModelBlock,newModel,parent,currentOutport,busObject,busName)
            busSelector=Simulink.ModelReference.Conversion.BusSelector(this.CreatedBusObjects,newModel,busObject);
            numberOfNewPorts=numel(busSelector.Outports);


            currentOutportPortHandles=get_param(currentOutport,'PortHandles');
            aLine=get_param(currentOutportPortHandles.Inport,'Line');
            srcPort=get_param(aLine,'SrcPortHandle');
            srcBlock=get_param(aLine,'SrcBlockHandle');
            delete(aLine);


            portNames=busSelector.OutportNames;
            baseName=get_param(currentOutport,'Name');



            set_param(currentOutport,'Name',sprintf('%s%s%s',baseName,this.SepChar,portNames{1}));


            pos=get_param(currentOutport,'Position');
            portHeight=pos(4)-pos(2);
            portDistance=2*portHeight;
            this.adjustBlkPosition(srcBlock,busSelector,currentOutport,...
            pos(2)+(numberOfNewPorts*portDistance-busSelector.BlkHeight-portHeight)/2);


            add_line(newModel,srcPort,busSelector.PortHandles.Inport,this.AddLineOpts{:});
            add_line(newModel,busSelector.PortHandles.Outport(1),currentOutportPortHandles.Inport,this.AddLineOpts{:});


            newModelOutports=find_system(newModel,'SearchDepth',1,'BlockType','Outport');
            aMask=newModelOutports==currentOutport;
            currentPortNumber=find(aMask);
            aModelName=get_param(newModel,'Name');
            pos=get_param(currentOutport,'Position');
            this.updatePortAttributes(currentOutport,busSelector.PortAttributes{1});

            for newPortIdx=2:numberOfNewPorts
                aPort=add_block('built-in/Outport',...
                sprintf('%s/%s%s%s',aModelName,baseName,this.SepChar,portNames{newPortIdx}),'MakeNameUnique','on');
                yshift=(newPortIdx-1)*portDistance;
                newPos=[pos(1),pos(2)+yshift,pos(3),pos(4)+yshift];
                set_param(aPort,'Position',newPos);
                set(aPort,'Port',num2str(currentPortNumber+newPortIdx-1));


                ph=get_param(aPort,'PortHandles');
                add_line(newModel,busSelector.PortHandles.Outport(newPortIdx),ph.Inport(1),this.AddLineOpts{:});


                this.updatePortAttributes(aPort,busSelector.PortAttributes{newPortIdx});
            end


            busCreator=Simulink.ModelReference.Conversion.BusCreator(this.CreatedBusObjects,parent,busObject);
            originalMask=this.OriginalNewModelOutports==currentOutport;
            dstBlock=this.OriginalWrapperSubsystemOutports(originalMask);


            aModelBlockObj=get_param(aModelBlock,'Object');
            aModelBlockObj.refreshModelBlock;
            aModelBlockPortHandles=get_param(aModelBlock,'PortHandles');


            pos=get_param(dstBlock,'Position');
            portHeight=pos(4)-pos(2);
            ypos=pos(2)-busCreator.BlkHeight/2+portHeight/2;
            this.adjustBlkPosition(aModelBlock,busCreator,dstBlock,ypos);


            portHandles=get_param(dstBlock,'PortHandles');
            aLine=add_line(parent,busCreator.PortHandles.Outport(1),portHandles.Inport(1),this.AddLineOpts{:});
            set_param(aLine,'Name',busName);


            for pIdx=1:numberOfNewPorts
                add_line(parent,aModelBlockPortHandles.Outport(currentPortNumber+pIdx-1),...
                busCreator.PortHandles.Inport(pIdx),this.AddLineOpts{:});
            end


            childBusSelector=busSelector.System;
            parentBusCreator=busCreator.System;
        end


        function resetInportAttributes(this,aPort,newSubsystemPortHandles,newSubsystemInports)
            ph=get_param(aPort,'PortHandles');
            aLine=get_param(ph.Outport,'Line');
            dstPort=get_param(aLine,'DstPortHandle');
            this.resetPortAttributes(newSubsystemInports(newSubsystemPortHandles.Inport==dstPort));
        end

        function resetOutportAttributes(this,aPort,newSubsystemPortHandles,newSubsystemOutports)
            ph=get_param(aPort,'PortHandles');
            aLine=get_param(ph.Inport,'Line');
            srcPort=get_param(aLine,'SrcPortHandle');
            this.resetPortAttributes(newSubsystemOutports(newSubsystemPortHandles.Outport==srcPort));
            this.resetPortAttributes(aPort);
        end

        function reconnectInports(this,parent,aModelBlock,newModel,disconnectedInports)
            aModelBlockPortHandles=get_param(aModelBlock,'PortHandles');
            for portIdx=1:numel(disconnectedInports)
                anInport=disconnectedInports(portIdx);
                srcInport=this.OriginalWrapperSubsystemInports(this.OriginalNewModelInports==anInport);
                ph=get_param(srcInport,'PortHandles');
                inports=find_system(newModel,'SearchDepth',1,'BlockType','Inport');
                dstPortBlock=aModelBlockPortHandles.Inport(inports==anInport);
                add_line(parent,ph.Outport,dstPortBlock,this.AddLineOpts{:});
                this.adjustInportPosition(anInport);
                this.adjustInportPosition(srcInport);
            end
        end

        function reconnectOutports(this,parent,aModelBlock,newModel,disconnectedOutports)
            aModelBlockPortHandles=get_param(aModelBlock,'PortHandles');
            for portIdx=1:numel(disconnectedOutports)
                aPort=disconnectedOutports(portIdx);
                dstOutport=this.OriginalWrapperSubsystemOutports(this.OriginalNewModelOutports==aPort);
                ph=get_param(dstOutport,'PortHandles');
                outports=find_system(newModel,'SearchDepth',1,'BlockType','Outport');
                srcPortBlock=aModelBlockPortHandles.Outport(outports==aPort);
                add_line(parent,srcPortBlock,ph.Inport,this.AddLineOpts{:});
                this.adjustOutportPosition(aPort);
                this.adjustOutportPosition(dstOutport);
            end
        end
    end

    methods(Static,Access=private)
        function adjustBlkPosition(firstBlk,busExpansionBlk,secondBlk,ypos)
            pos1=get(firstBlk,'Position');
            pos3=get(secondBlk,'Position');
            firstWidth=pos1(3)-pos1(1);
            thirdWidth=pos3(3)-pos3(1);
            x_distance=2*min(firstWidth,thirdWidth);


            xpos=pos1(3)+x_distance;
            pos=[xpos,ypos,xpos+busExpansionBlk.BlkWidth,ypos+busExpansionBlk.BlkHeight];
            set(busExpansionBlk.System,'Position',pos);


            blkWidth=pos3(3)-pos3(1);
            xpos=pos1(3)+2*x_distance+busExpansionBlk.BlkWidth;
            pos=[xpos,pos3(2),xpos+blkWidth,pos3(4)];
            set(secondBlk,'Position',pos);
        end

        function adjustInportPosition(aPort)
            ph=get_param(aPort,'PortHandles');
            aLine=get_param(ph.Outport,'Line');
            dstPort=get_param(aLine,'DstPortHandle');
            srcPort=get_param(aLine,'SrcPortHandle');
            dstPos=get_param(dstPort,'Position');
            pos=get_param(aPort,'Position');
            blkWidth=pos(3)-pos(1);
            blkHeight=pos(4)-pos(2);
            newPos=[dstPos(1)-3*blkWidth,dstPos(2)-blkHeight/2,dstPos(1)-2*blkWidth,dstPos(2)+blkHeight/2];

            if max(newPos)<32767
                set_param(aPort,'Position',newPos);
            end


            delete(aLine);
            parent=get_param(get_param(aPort,'Parent'),'Handle');
            add_line(parent,srcPort,dstPort);
        end

        function adjustOutportPosition(aPort)
            ph=get_param(aPort,'PortHandles');
            aLine=get_param(ph.Inport,'Line');
            dstPort=get_param(aLine,'DstPortHandle');
            srcPort=get_param(aLine,'SrcPortHandle');
            dstPos=get_param(srcPort,'Position');
            pos=get_param(aPort,'Position');
            blkWidth=pos(3)-pos(1);
            blkHeight=pos(4)-pos(2);
            newPos=[dstPos(1)+2*blkWidth,dstPos(2)-blkHeight/2,dstPos(1)+3*blkWidth,dstPos(2)+blkHeight/2];
            if max(newPos)<32767
                set_param(aPort,'Position',newPos);
            end


            parent=get_param(get_param(aPort,'Parent'),'Handle');
            delete(aLine);
            add_line(parent,srcPort,dstPort);
        end

        function updatePortAttributes(aPort,dataObj)
            set_param(aPort,'OutDataTypeStr',dataObj.DataType);
            set_param(aPort,'SampleTime','-1');
            set_param(aPort,'PortDimensions',num2str(dataObj.Dimensions));
            set_param(aPort,'DimensionsMode',dataObj.DimensionsMode);
            set_param(aPort,'VarSizeSig','inherit');
            set_param(aPort,'SignalType','auto');
            set_param(aPort,'Unit',dataObj.Unit);
            set_param(aPort,'Description',dataObj.Description);
            set_param(aPort,'OutDataTypeStr',dataObj.DataType);
        end

        function resetPortAttributes(aPort)
            set_param(aPort,'OutDataTypeStr','Inherit: auto');
            set_param(aPort,'SampleTime','-1');
            set_param(aPort,'PortDimensions','-1');
            set_param(aPort,'VarSizeSig','inherit');
            set_param(aPort,'SignalType','auto');
        end
    end
end


