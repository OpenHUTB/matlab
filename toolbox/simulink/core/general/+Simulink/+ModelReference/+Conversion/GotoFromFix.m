classdef GotoFromFix<Simulink.ModelReference.Conversion.AutoFix




    properties(SetAccess=protected,GetAccess=protected)
System
GotoBlocks
CompiledPortInfos
CompiledPortInfoMap
Results
ConversionData
    end

    methods(Access=public)
        function fix(this)
            for idx=1:numel(this.GotoBlocks)
                this.update(this.System,this.GotoBlocks(idx),this.CompiledPortInfos{idx});
            end
        end


        function results=getActionDescription(this)
            results=this.Results;
        end
    end


    methods(Access=protected)
        function this=GotoFromFix(subsys,gotoBlocks,portInfos,params,portInfoMap)
            this.System=subsys;
            this.GotoBlocks=gotoBlocks;
            this.CompiledPortInfos=portInfos;
            this.ConversionData=params;
            this.IsModifiedSystemInterface=true;
            this.CompiledPortInfoMap=portInfoMap;
        end
    end


    methods(Abstract,Access=protected)
        update(this,subsysH,gotoBlock,portInfo)
    end


    methods(Static,Access=protected)
        function blkH=addBlock(subsysH,blkName,blkType)
            blkH=add_block(blkType,[getfullname(subsysH),'/',blkName],'makenameunique','on');
        end


        function lineH=connectTwoBlocks(parentSubsystem,srcBlk,dstBlk)
            srcBlkHandles=get_param(srcBlk,'PortHandles');
            dstBlkHandles=get_param(dstBlk,'PortHandles');
            lineH=add_line(parentSubsystem,srcBlkHandles.Outport(1),dstBlkHandles.Inport(1),...
            Simulink.ModelReference.Conversion.GuiUtilities.AddLineOpts{:});
        end


        function lineH=connectBlockToSubsystem(parentSubsystem,srcBlk,subsys)
            portHandles=get_param(subsys,'PortHandles');
            srcBlkHandles=get_param(srcBlk,'PortHandles');
            lineH=add_line(parentSubsystem,srcBlkHandles.Outport(1),portHandles.Inport(end),...
            Simulink.ModelReference.Conversion.GuiUtilities.AddLineOpts{:});
        end


        function lineH=connectSubsystemToBlock(parentSubsystem,subsys,desBlk)
            portHandles=get_param(subsys,'PortHandles');
            dstBlkHandles=get_param(desBlk,'PortHandles');
            lineH=add_line(parentSubsystem,portHandles.Outport(end),dstBlkHandles.Inport(1),...
            Simulink.ModelReference.Conversion.GuiUtilities.AddLineOpts{:});
        end
    end


    properties(Constant,GetAccess=protected)
        findOptions={'SearchDepth',1,'LookUnderMasks','all','IncludeCommented','on'};
    end

    methods(Static,Access=public)
        function[xmin,ymax,xmax]=guessInitialPosition(subsys)
            blks=find_system(subsys,Simulink.ModelReference.Conversion.GotoFromFix.findOptions{:});
            pos=Simulink.ModelReference.Conversion.Utilities.cellify(get_param(blks(2:end),'Position'));
            pos=cell2mat(pos);
            xmin=min(pos(:,1));
            ymax=max(pos(:,4));
            xmax=max(pos(:,3));
        end

        function[portWidth,portHeight]=guessPortSize(subsys,blkType)
            ports=find_system(subsys,Simulink.ModelReference.Conversion.GotoFromFix.findOptions{:},'BlockType',blkType);
            if~isempty(ports)
                [portWidth,portHeight]=Simulink.ModelReference.Conversion.GotoFromFix.getBlockSize(ports(1));
            else
                portWidth=30;
                portHeight=14;
            end
        end
    end

    methods(Static,Access=private)
        function[width,height]=getBlockSize(aBlk)
            pos=get_param(aBlk,'Position');
            width=pos(3)-pos(1);
            height=pos(4)-pos(2);
        end
    end
end
