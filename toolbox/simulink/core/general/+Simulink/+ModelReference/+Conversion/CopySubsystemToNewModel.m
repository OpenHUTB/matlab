


classdef CopySubsystemToNewModel<handle
    properties(SetAccess=private,GetAccess=public)
System
DstModel
DstModelName
PortHandles
OrigSystemPortHandles

Position

        InportWidth=30;
        InportHeight=14;

        OutportWidth=30;
        OutportHeight=14;

        ss2MdlVirtualBusCrossNoBusObj=false;
        CreateBusObjectsForAllBuses=false;
        portExpansionTable=[];
        isRightClickBuild=false;
        isSampleTimeIndependent=false;
    end

    properties(Constant,Access=private)
        FindOpts={'LookUnderMasks','on','SearchDepth',1,...
        'MatchFilter',@Simulink.match.allVariants,'FollowLinks','on'};
    end

    methods(Static,Access=public)
        function copy(subsys,dstModel,createBusObjectsForAllBuses,portExpansionTable,isRightClickBuild,isSampleTimeIndenpent)
            this=Simulink.ModelReference.Conversion.CopySubsystemToNewModel(subsys,dstModel,createBusObjectsForAllBuses);
            this.portExpansionTable=portExpansionTable;
            this.isRightClickBuild=isRightClickBuild;
            this.isSampleTimeIndependent=isSampleTimeIndenpent;
            this.exec;
        end



        function setPositionAssociatesWithPorts(isInport,dstModel,portHandle,blockHandle,subsystemOrientation,signalNameFromLabel)
            portPosition=get_param(portHandle,'Position');
            blockPosition=get_param(blockHandle,'Position');
            blockHeight=blockPosition(4)-blockPosition(2);
            blockWidth=blockPosition(3)-blockPosition(1);

            blockPorts=get_param(blockHandle,'PortHandles');
            if isInport
                lineHandle=add_line(dstModel,blockPorts.Outport,portHandle);
            else
                lineHandle=add_line(dstModel,portHandle,blockPorts.Inport);
            end

            if~isempty(signalNameFromLabel)
                set_param(lineHandle,'SignalNameFromLabel',signalNameFromLabel);
            end

            set_param(blockHandle,'Orientation',subsystemOrientation);
            switch subsystemOrientation
            case 'right'
                if isInport
                    relocatePosition=[portPosition(1)-blockWidth*2,portPosition(2)-blockHeight/2,portPosition(1)-blockWidth,portPosition(2)+blockHeight/2];
                else
                    relocatePosition=[portPosition(1)+blockWidth,portPosition(2)-blockHeight/2,portPosition(1)+blockWidth*2,portPosition(2)+blockHeight/2];
                end
            case 'left'
                if isInport
                    relocatePosition=[portPosition(1)+blockWidth,portPosition(2)-blockHeight/2,portPosition(1)+blockWidth*2,portPosition(2)+blockHeight/2];
                else
                    relocatePosition=[portPosition(1)-blockWidth*2,portPosition(2)-blockHeight/2,portPosition(1)-blockWidth,portPosition(2)+blockHeight/2];
                end
            case 'up'
                if isInport
                    relocatePosition=[portPosition(1)-blockWidth/2,portPosition(2)+blockHeight,portPosition(1)+blockWidth/2,portPosition(2)+blockHeight*2];
                else
                    relocatePosition=[portPosition(1)-blockWidth/2,portPosition(2)-blockHeight*2,portPosition(1)+blockWidth/2,portPosition(2)-blockHeight];
                end
            case 'down'
                if isInport
                    relocatePosition=[portPosition(1)-blockWidth/2,portPosition(2)-blockHeight*2,portPosition(1)+blockWidth/2,portPosition(2)-blockHeight];

                else
                    relocatePosition=[portPosition(1)-blockWidth/2,portPosition(2)+blockHeight,portPosition(1)+blockWidth/2,portPosition(2)+blockHeight*2];
                end
            end
            set_param(blockHandle,'Position',relocatePosition);
        end

    end

    methods(Access=private)
        function this=CopySubsystemToNewModel(subsys,dstModel,createBusObjectsForAllBuses)
            this.System=subsys;
            this.DstModel=dstModel;
            this.DstModelName=get_param(this.DstModel,'Name');
            this.ss2MdlVirtualBusCrossNoBusObj=1;
            this.CreateBusObjectsForAllBuses=createBusObjectsForAllBuses;
        end

        function exec(this)
            this.copySubsystem;
            this.copyInports;
            this.copyOutports;
            this.copyConditionalExecutePorts;
        end

        function copySubsystem(this)
            blkName=get_param(this.System,'Name');
            newSubsys=add_block(this.System,[this.DstModelName,'/',Simulink.ModelReference.Conversion.Utilities.getARandomName()],'MakeNameUnique','on');
            set_param(newSubsys,'Name',blkName);
            this.PortHandles=get_param(newSubsys,'PortHandles');
            this.OrigSystemPortHandles=get_param(this.System,'PortHandles');
            this.Position=get_param(newSubsys,'Position');
            ginfo=Simulink.ModelReference.Conversion.CopyGraphicalInfo.create(this.System);
            ginfo.copy(newSubsys);
        end

        function portContainsVardims=getPortContainsVardims(~,portHandle)
            portContainsVardims=(sum(get_param(portHandle,'CompiledPortDimensionsMode'))~=0);
        end

        function setGeneralPorts(this,isInport,blks,idx,x,y,y_distance)

            modelName=get_param(this.DstModel,'Name');
            aBlk=blks(idx);
            blkName=get_param(aBlk,'Name');
            realPortIdx=str2double(get_param(aBlk,'Port'));
            origPortName=get_param(aBlk,'PortName');
            if Simulink.ModelReference.Conversion.isBusElementPort(aBlk)
                if isInport
                    if strcmp(get_param(this.OrigSystemPortHandles.Inport(realPortIdx),'CompiledBusType'),'NON_VIRTUAL_BUS')||~slInternal('isPureVirtualBus',this.OrigSystemPortHandles.Inport(realPortIdx))
                        if get_param(this.PortHandles.Inport(realPortIdx),'Line')~=-1
                            return;
                        end
                        aPortBlock=this.addBlock(aBlk,'simulink/Ports & Subsystems/In1');


                        new_y=y+(idx-1)*(y_distance+this.InportHeight);
                        pos=[x,new_y,x+this.InportWidth,new_y+this.InportHeight];
                        set_param(aPortBlock,'Position',pos);


                        ph=get_param(aPortBlock,'PortHandles');
                        add_line(this.DstModel,ph.Outport(1),this.PortHandles.Inport(realPortIdx),'autorouting','on');


                        signalHierarchy=get_param(this.OrigSystemPortHandles.Inport(realPortIdx),'SignalHierarchy');
                        busName=signalHierarchy.BusObject;
                        if~isempty(busName)
                            set_param(aPortBlock,'OutDataTypeStr',['Bus: ',busName]);
                            set_param(aPortBlock,'BusOutputAsStruct','on');
                        end
                    else
                        if get_param(this.PortHandles.Inport(realPortIdx),'Line')~=-1
                            return;
                        end
                        busElementIn=add_block('simulink/Ports & Subsystems/In Bus Element',[modelName,'/In Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Element','');
                        set_param(busElementIn,'PortName',origPortName);


                        ph=get_param(busElementIn,'PortHandles');
                        add_line(this.DstModel,ph.Outport(1),this.PortHandles.Inport(realPortIdx),'autorouting','on');

                    end
                else
                    if strcmp(get_param(this.OrigSystemPortHandles.Outport(realPortIdx),'CompiledBusType'),'NON_VIRTUAL_BUS')||~slInternal('isPureVirtualBus',this.OrigSystemPortHandles.Outport(realPortIdx))
                        if get_param(this.PortHandles.Outport(realPortIdx),'Line')~=-1
                            return;
                        end
                        aPortBlock=this.addBlock(aBlk,'simulink/Ports & Subsystems/Out1');


                        new_y=y+(idx-1)*(y_distance+this.InportHeight);
                        pos=[x,new_y,x+this.InportWidth,new_y+this.InportHeight];
                        set_param(aPortBlock,'Position',pos);


                        ph=get_param(aPortBlock,'PortHandles');
                        add_line(this.DstModel,this.PortHandles.Outport(realPortIdx),ph.Inport(1),'autorouting','on');


                        signalHierarchy=get_param(this.OrigSystemPortHandles.Outport(realPortIdx),'SignalHierarchy');
                        busName=signalHierarchy.BusObject;
                        if~isempty(busName)
                            set_param(aPortBlock,'OutDataTypeStr',['Bus: ',busName]);
                        end
                        set_param(aPortBlock,'BusOutputAsStruct','on');
                    else
                        if get_param(this.PortHandles.Outport(realPortIdx),'Line')~=-1
                            return;
                        end
                        busElementOut=add_block('simulink/Ports & Subsystems/Out Bus Element',[modelName,'/Out Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Element','');
                        set_param(busElementOut,'PortName',origPortName);


                        ph=get_param(busElementOut,'PortHandles');
                        add_line(this.DstModel,this.PortHandles.Outport(realPortIdx),ph.Inport(1),'autorouting','on')
                    end
                end

            else
                aPortBlock=this.addBlock(aBlk,aBlk);


                new_y=y+(idx-1)*(y_distance+this.InportHeight);
                pos=[x,new_y,x+this.InportWidth,new_y+this.InportHeight];
                set_param(aPortBlock,'Position',pos);


                ph=get_param(aPortBlock,'PortHandles');
                if isInport
                    add_line(this.DstModel,ph.Outport(1),this.PortHandles.Inport(realPortIdx),'autorouting','on');
                else
                    add_line(this.DstModel,this.PortHandles.Outport(realPortIdx),ph.Inport(1),'autorouting','on');
                end
            end
        end

        function copyInports(this)
            blks=find_system(this.System,this.FindOpts{:},'BlockType','Inport');
            if~isempty(blks)
                [this.InportWidth,this.InportHeight]=this.getBlkSizes(blks(1));
            end


            x_distance=4*this.InportWidth;
            y_distance=2*this.InportWidth;

            x=this.Position(1)-x_distance;
            y=this.computeYPos(this.Position,numel(this.PortHandles.Inport),y_distance,this.InportHeight);

            for idx=1:numel(blks)
                realPortIdx=str2double(get_param(blks(idx),'Port'));
                portName=this.makeNewBlockNameFromOriginalName(get_param(blks(idx),'PortName'));

                [portCanExpanded,addRTB]=this.canPortBeExpandedAndAddRTB(this.OrigSystemPortHandles.Inport(realPortIdx));
                if portCanExpanded



                    subsystemOrientation=get_param(this.System,'Orientation');
                    signalHierarchy=get_param(this.OrigSystemPortHandles.Inport(realPortIdx),'SignalHierarchy');
                    compiledBusStruct=get_param(this.OrigSystemPortHandles.Inport(realPortIdx),'CompiledBusStruct');



                    if~isempty(compiledBusStruct.srcSignalName)&&isempty(signalHierarchy.SignalName)
                        signalHierarchy.SignalName=compiledBusStruct.srcSignalName;
                    end



                    Simulink.ModelReference.Conversion.BusExpansionBlock.drawExpandedvirtualBusCreator(this.DstModel,...
                    signalHierarchy,...
                    this.PortHandles.Inport(realPortIdx),...
                    '',...
                    subsystemOrientation,true,0,portName,addRTB,...
                    [],0,false,this.isRightClickBuild,this.isSampleTimeIndependent);
                else
                    this.setGeneralPorts(true,blks,idx,x,y,y_distance);
                end
            end
        end

        function[portCanExpanded,addRTB]=canPortBeExpandedAndAddRTB(this,portHandle)
            if isKey(this.portExpansionTable,portHandle)
                expTable=this.portExpansionTable(portHandle);
                if iscell(expTable)
                    expTable=expTable{:};
                end
                portCanExpanded=expTable(1);
                addRTB=expTable(2);
            else
                portCanExpanded=false;
                addRTB=false;
            end
        end

        function copyOutports(this)
            modelName=get_param(this.DstModel,'Name');
            subsystemRotation=get_param(this.System,'Orientation');

            blks=find_system(this.System,this.FindOpts{:},'BlockType','Outport');
            if~isempty(blks)
                [this.OutportWidth,this.OutportHeight]=this.getBlkSizes(blks(1));
            end


            x_distance=3*this.OutportWidth;
            y_distance=2*this.OutportHeight;

            x=this.Position(3)+x_distance;
            y=this.computeYPos(this.Position,numel(this.PortHandles.Inport),y_distance,this.InportHeight);
            for idx=1:numel(blks)
                realPortIdx=str2double(get_param(blks(idx),'Port'));
                portName=this.makeNewBlockNameFromOriginalName(get_param(blks(idx),'PortName'));
                if(get_param(this.PortHandles.Outport(realPortIdx),'Line')==-1)
                    [portCanExpanded,addRTB]=this.canPortBeExpandedAndAddRTB(this.OrigSystemPortHandles.Outport(realPortIdx));
                    if portCanExpanded
                        signalHierarchy=get_param(this.OrigSystemPortHandles.Outport(realPortIdx),'SignalHierarchy');
                        signalNameFromLabel=signalHierarchy.SignalName;
                        signalHierarchy.SignalName='';

                        signalVecs=Simulink.ModelReference.Conversion.PortUtils.flattenSignalHierarchy(signalHierarchy);
                        signalCommaSepList=strjoin(signalVecs,',');


                        if addRTB
                            rateTransitionHandle=add_block('simulink/Signal Attributes/Rate Transition',[modelName,'/Rate Transition'],'MakeNameUnique','on');
                            Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,this.DstModel,this.PortHandles.Outport(realPortIdx),rateTransitionHandle,subsystemRotation,signalNameFromLabel);
                            rateTransitionPorts=get_param(rateTransitionHandle,'PortHandles');
                            rateTransitionOutport=rateTransitionPorts.Outport;

                            busSelectorHandle=add_block('simulink/Commonly Used Blocks/Bus Selector',[modelName,'/busSelector'],'MakeNameUnique','on');
                            set_param(busSelectorHandle,'OutputSignals',signalCommaSepList);

                            Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,this.DstModel,rateTransitionOutport,busSelectorHandle,subsystemRotation,signalNameFromLabel);
                        else
                            busSelectorHandle=add_block('simulink/Commonly Used Blocks/Bus Selector',[modelName,'/busSelector'],'MakeNameUnique','on');
                            set_param(busSelectorHandle,'OutputSignals',signalCommaSepList);
                            Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,this.DstModel,this.PortHandles.Outport(realPortIdx),busSelectorHandle,subsystemRotation,signalNameFromLabel);
                        end


                        busSelectorOutports=get_param(busSelectorHandle,'PortHandles');
                        busSelectorOutports=busSelectorOutports.Outport;

                        if numel(signalVecs)>=1
                            busElementOut=add_block('simulink/Ports & Subsystems/Out Bus Element',[modelName,'/Out Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Element',signalVecs{1});
                            set_param(busElementOut,'PortName',portName);
                            Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,this.DstModel,busSelectorOutports(1),busElementOut,subsystemRotation,'');
                        end

                        for sigIdx=2:numel(signalVecs)
                            busElementOutAdded=add_block(busElementOut,[modelName,'/Out Bus Element'],'MakeNameUnique','on','Element',signalVecs{sigIdx});
                            Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,this.DstModel,busSelectorOutports(sigIdx),busElementOutAdded,subsystemRotation,'');
                        end
                    else
                        this.setGeneralPorts(false,blks,idx,x,y,y_distance);
                    end
                end
            end
        end

        function copyConditionalExecutePorts(this)
            this.addNewInport(this.PortHandles.Trigger,'TriggerPort');
            this.addNewInport(this.PortHandles.Ifaction,'ActionPort');
            this.addNewInport(this.PortHandles.Enable,'EnablePort');
            this.addNewInport(this.PortHandles.Reset,'ResetPort');
        end

        function addNewInport(this,portHandles,portType)
            if~isempty(portHandles)
                ports=find_system(this.System,this.FindOpts{:},'BlockType',portType);
                N=numel(portHandles);
                for idx=1:N
                    aPort=this.addBlock(ports(idx),'built-in/Inport');


                    pos=get_param(portHandles(idx),'Position');
                    new_x=pos(1)-2*this.InportWidth;
                    new_y=pos(2)-3*this.InportHeight;
                    set_param(aPort,'Position',[new_x,new_y,new_x+this.InportWidth,new_y+this.InportHeight]);


                    ph=get_param(aPort,'PortHandles');
                    add_line(this.DstModel,ph.Outport(1),portHandles(idx),'autorouting','on');
                end
            end
        end

        function blk=addBlock(this,origPortHandle,blockNameInLibrary)
            blkName=get_param(origPortHandle,'Name');


            blkName=this.makeNewBlockNameFromOriginalName(blkName);

            blk=add_block(blockNameInLibrary,[this.DstModelName,'/',blkName]);
        end

        function[blockName]=makeNewBlockNameFromOriginalName(this,blockName)






            blockName=replace(blockName,'/','//');


            if getSimulinkBlockHandle([this.DstModelName,'/',blockName])>0



                tempName=Simulink.ModelReference.Conversion.Utilities.getARandomName();



                tempName=replace(tempName,'temp',blockName);



                assert(1==regexp(tempName,[blockName,'_\d+']),...
                ['tempName must match the pattern "',blockName,'_\d+" in ',...
                mfilename('fullpath')]);


                blockName=tempName;
            end
        end
    end

    methods(Static,Access=private)
        function[width,height]=getBlkSizes(aBlk)
            pos=get_param(aBlk,'Position');
            width=pos(3)-pos(1);
            height=pos(4)-pos(2);
        end

        function y=computeYPos(pos,numberOfPorts,y_distance,portHeight)
            y=(pos(4)+pos(2))/2;
            if~mod(numberOfPorts,2)
                y=y+y_distance/2;
            end
            y=y-floor(numberOfPorts/2)*(y_distance+portHeight)-portHeight/2;
        end
    end
end


