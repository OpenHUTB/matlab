classdef BusCreator<Simulink.ModelReference.Conversion.BusExpansionBlock
    methods(Access=public)
        function this=BusCreator(createdBusObj,parent,busObject)
            this@Simulink.ModelReference.Conversion.BusExpansionBlock(createdBusObj,parent,busObject);
        end
    end

    methods(Access=protected)
        function aLine=add_line(this,dstPort,srcPort)
            aLine=add_line(this.System,srcPort,dstPort,this.AddLineOpts{:});
        end

        function blk=addBusExpansionBlock(this,currentHeight,currentDepth)
            blk=this.add_block(this.BusCreatorID,[this.SystemName,'Bus Creator'],...
            currentHeight,currentDepth,this.BlkWidth,this.BlkHeight);
            this.setOrienation(blk);
            this.Blks(end+1)=blk;
        end

        function blk=addPort(this,portName,currentHeight,currentDepth)
            blk=this.add_block(this.InportID,[this.SystemName,portName],...
            currentHeight,currentDepth,this.PortWidth,this.PortHeight);
            this.setOrienation(blk);
            this.Inports(end+1)=blk;
            this.InportNames{end+1}=portName;
        end

        function setupBusExpansionBlock(~,block,busElements)
            set_param(block,'Inputs',num2str(numel(busElements)));
        end

        function init(this)
            currentHeight=1;
            this.Outports(1)=this.add_block(this.OutportID,[this.SystemName,'Out'],...
            currentHeight,1,this.PortWidth,this.PortHeight);
            this.OutportNames{1}='Out';
            this.setOrienation(this.Outports(1));
            this.CurrentDepth(currentHeight)=1;


            currentHeight=currentHeight+1;
            parentBlock=this.addBusExpansionBlock(currentHeight,1);
            this.CurrentDepth(currentHeight)=1;
            this.Blks(1)=parentBlock;


            portHandles=get_param(this.Outports(1),'PortHandles');
            parentHandles=get_param(parentBlock,'PortHandles');
            add_line(this.System,parentHandles.Outport(1),portHandles.Inport(1),this.AddLineOpts{:});
        end

        function updateSignalInfo(this,aLine,dataObj)%#ok
            set_param(aLine,'Name',dataObj.Name);
        end
    end

    methods(Static,Access=protected)
        function ssName=getInitName()
            ssName='Bus_Creator';
        end
    end

    methods(Static,Access=private)
        function setOrienation(blk)
            set_param(blk,'Orientation','left');
        end
    end
end
