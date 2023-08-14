classdef BusSelector<Simulink.ModelReference.Conversion.BusExpansionBlock
    methods(Access=public)
        function this=BusSelector(createdBusObj,parent,busObject)
            this@Simulink.ModelReference.Conversion.BusExpansionBlock(createdBusObj,parent,busObject);
        end
    end

    methods(Access=protected)
        function aLine=add_line(this,srcPort,dstPort)
            aLine=add_line(this.System,srcPort,dstPort,this.AddLineOpts{:});
        end

        function blk=addBusExpansionBlock(this,currentHeight,currentDepth)
            blk=this.add_block(this.BusSelectorID,[this.SystemName,'Bus Selector'],...
            currentHeight,currentDepth,this.BlkWidth,this.BlkHeight);
            this.Blks(end+1)=blk;
        end

        function blk=addPort(this,portName,currentHeight,currentDepth)
            blk=this.add_block(this.OutportID,[this.SystemName,portName],...
            currentHeight,currentDepth,this.PortWidth,this.PortHeight);
            this.Outports(end+1)=blk;
            this.OutportNames{end+1}=portName;
        end

        function setupBusExpansionBlock(~,block,busElements)
            N=numel(busElements);
            busStr=busElements(1).Name;
            for idx=2:N
                busStr=sprintf('%s,%s',busStr,busElements(idx).Name);
            end
            set_param(block,'OutputSignals',busStr);
        end

        function init(this)
            currentHeight=1;
            this.Inports(end+1)=this.add_block(this.InportID,[this.SystemName,'In'],...
            currentHeight,1,this.PortWidth,this.PortHeight);
            this.InportNames{1}='In';
            this.CurrentDepth(currentHeight)=1;


            currentHeight=currentHeight+1;
            parentBlock=this.addBusExpansionBlock(currentHeight,1);
            this.CurrentDepth(currentHeight)=1;
            this.Blks(1)=parentBlock;


            portHandles=get_param(this.Inports(1),'PortHandles');
            parentHandles=get_param(parentBlock,'PortHandles');
            add_line(this.System,portHandles.Outport(1),parentHandles.Inport(1),this.AddLineOpts{:});
        end

        function updateSignalInfo(this,aLine,dataObj)%#ok
        end
    end

    methods(Static,Access=protected)
        function ssName=getInitName()
            ssName='Bus_Selector';
        end
    end
end
