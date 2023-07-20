



classdef BusExpansionBlock<handle



    properties(SetAccess=protected,GetAccess=public)
Model
System
SystemName
        Inports=[]
        Outports=[]

        InportNames={}
        OutportNames={}

        BlkWidth=10;
        BlkHeight=40;

PortHandles
        PortAttributes={}
    end

    properties(SetAccess=protected,GetAccess=protected)
InitName
CreatedBusObjects
        Blks=[]

        XPos=60;
        YPos=42;

        PortWidth=30;
        PortHeight=14;

        CurrentHeight=1;
CurrentDepth
    end

    properties(Constant)
        AddBlockOpts={'MakeNameUnique','on'};
        AddLineOpts={'AutoRouting','on'};
        BusSelectorID='simulink/Signal Routing/Bus Selector';
        BusCreatorID='simulink/Signal Routing/Bus Creator';
        InportID='built-in/Inport';
        OutportID='built-in/Outport';
    end

    methods(Access=public)
        function this=BusExpansionBlock(createdBusObj,parent,busObject)
            this.CreatedBusObjects=createdBusObj;
            this.Model=bdroot(parent);
            this.CurrentDepth=containers.Map('KeyType','uint32','ValueType','uint32');

            [this.PortWidth,this.PortHeight]=Simulink.ModelReference.Conversion.Utilities.computePortSize(parent);


            ssName=[getfullname(parent),'/',this.getInitName];
            this.System=this.add_block('built-in/SubSystem',ssName,1,1,this.BlkWidth,this.BlkHeight);
            this.SystemName=[getfullname(this.System),'/'];


            this.init;


            currentHeight=3;
            currentDepth=1;
            this.insert(this.Blks(1),busObject,currentHeight,currentDepth);


            pos=get_param(this.System,'Position');


            fontSize=get(this.Model,'DefaultBlockFontSize');
            this.BlkWidth=fontSize*max(max(cellfun(@(s)length(s),this.InportNames)),...
            max(cellfun(@(s)length(s),this.OutportNames)));

            this.BlkHeight=max(numel(this.Inports),numel(this.Outports))*this.PortHeight;
            set_param(this.System,'Position',[pos(1),pos(2),pos(1)+this.BlkWidth,pos(2)+this.BlkHeight]);


            this.PortHandles=get_param(this.System,'PortHandles');
        end
    end


    methods(Abstract,Access=protected)
        aLine=add_line(this,srcPort,dstPort)
        blk=addBusExpansionBlock(this,currentHeight,currentDepth);
        blk=addPort(this,portName,currentHeight,currentDepth);
        setupBusExpansionBlock(this,busElements);
        init(this,parent,busObject);
        updateSignalInfo(this,aLine,dataObj);
    end

    methods(Abstract,Static,Access=protected)
        ssName=getInitName();
    end

    methods(Access=protected)
        function insert(this,parentBlock,busObject,currentHeight,suggestedDepth)
            N=numel(busObject.Elements);
            if N>0
                this.setupBusExpansionBlock(parentBlock,busObject.Elements);
            end


            for idx=1:N
                dataObj=busObject.Elements(idx);
                dataID=dataObj.DataType;
                currentDepth=max(this.getCurrentDepth(currentHeight),suggestedDepth+idx-1);


                aMask=strcmp(dataID,this.CreatedBusObjects.BusNames);
                if any(aMask)
                    subBusObj=this.CreatedBusObjects.BusObjects{aMask};
                    blk=this.addBusExpansionBlock(currentHeight,currentDepth);
                    this.insert(blk,subBusObj,currentHeight+1,currentDepth);
                else
                    this.PortAttributes{end+1}=dataObj;
                    blk=this.addPort(dataObj.Name,currentHeight,currentDepth);
                end


                aLine=this.add_line([get_param(parentBlock,'Name'),'/',num2str(idx)],...
                [get_param(blk,'Name'),'/1']);


                this.updateSignalInfo(aLine,dataObj);
            end
        end

        function blk=add_block(this,srcBlk,dstBlk,currentHeight,currentDepth,blkHeight,blkWidth)
            blk=add_block(srcBlk,dstBlk,this.AddBlockOpts{:});
            this.setBlkPosition(blk,currentHeight,currentDepth,blkWidth,blkHeight);
        end

        function setBlkPosition(this,blk,currentHeight,currentDepth,blkHeight,blkWidth)
            blkPos=[currentHeight*this.XPos,currentDepth*this.YPos,...
            currentHeight*this.XPos+blkWidth,currentDepth*this.YPos+blkHeight];
            if max(blkPos)<32767
                set_param(blk,'Position',double(blkPos));
            end
        end

        function currentDepth=getCurrentDepth(this,currentHeight)
            if this.CurrentDepth.isKey(currentHeight)
                currentDepth=this.CurrentDepth(currentHeight)+1;
            else
                currentDepth=1;
            end
            this.CurrentDepth(currentHeight)=currentDepth;
        end
    end

    methods(Static,Access=public)
        function[busElementIn,index]=drawExpandedvirtualBusCreator(dstModel,...
            signalHierarchy,portHandle,signalName,subsystemRotation,createNewPort,...
            busElementIn,portName,addRTB,expandedPortInfo,index,isGotoFrom,isRightClickBuild,isSampleTimeIndependent)
            if get_param(portHandle,'Line')~=-1
                return;
            end
            modelName=get_param(dstModel,'Name');
            signalNameFromLabel=signalHierarchy.SignalName;




            if isempty(signalHierarchy.Children)
                if createNewPort
                    busElementIn=add_block('simulink/Ports & Subsystems/In Bus Element',[modelName,'/In Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Element',signalName);
                else
                    busElementIn=add_block(busElementIn,[modelName,'/In Bus Element'],'MakeNameUnique','on','Element',signalName);
                end

                if isGotoFrom
                    Simulink.ModelReference.Conversion.PortUtils.setBEPsExpandedFromPureVirtualBus(busElementIn,expandedPortInfo(index),isRightClickBuild);
                    if~isSampleTimeIndependent
                        set_param(busElementIn,'SampleTime',mat2str(expandedPortInfo(index).Attribute.SampleTime));
                    end
                    index=index+1;
                elseif createNewPort
                    set_param(busElementIn,'PortName',portName);
                end
                Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(true,dstModel,portHandle,busElementIn,subsystemRotation,signalNameFromLabel);
            else

                if addRTB
                    rateTransitionHandle=add_block('simulink/Signal Attributes/Rate Transition',[modelName,'/Rate Transition'],'MakeNameUnique','on');
                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(true,dstModel,portHandle,rateTransitionHandle,subsystemRotation,signalNameFromLabel);
                    rateTransitionPorts=get_param(rateTransitionHandle,'PortHandles');
                    rateTransitionInport=rateTransitionPorts.Inport;
                    portHandle=rateTransitionInport;
                end
                busCreatorHandle=add_block('simulink/Commonly Used Blocks/Bus Creator',[modelName,'/busCreator'],'MakeNameUnique','on');
                set_param(busCreatorHandle,'Inputs',num2str(numel(signalHierarchy.Children)));
                busCreatorPortHandles=get_param(busCreatorHandle,'PortHandles');
                Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(true,dstModel,portHandle,busCreatorHandle,subsystemRotation,signalNameFromLabel);

                if isempty(signalName)
                    sigName=signalHierarchy.Children(1).SignalName;
                else
                    sigName=[signalName,'.',signalHierarchy.Children(1).SignalName];
                end

                [busElementIn,index]=Simulink.ModelReference.Conversion.BusExpansionBlock.drawExpandedvirtualBusCreator(dstModel,signalHierarchy.Children(1),...
                busCreatorPortHandles.Inport(1),sigName,subsystemRotation,createNewPort,busElementIn,portName,false,...
                expandedPortInfo,index,isGotoFrom,isRightClickBuild,isSampleTimeIndependent);
                for ii=2:numel(signalHierarchy.Children)
                    if isempty(signalName)
                        sigName=signalHierarchy.Children(ii).SignalName;
                    else
                        sigName=[signalName,'.',signalHierarchy.Children(ii).SignalName];
                    end
                    [~,index]=Simulink.ModelReference.Conversion.BusExpansionBlock.drawExpandedvirtualBusCreator(dstModel,...
                    signalHierarchy.Children(ii),busCreatorPortHandles.Inport(ii),sigName,subsystemRotation,false,...
                    busElementIn,portName,false,expandedPortInfo,index,isGotoFrom,isRightClickBuild,isSampleTimeIndependent);
                end
            end
        end
    end
end
