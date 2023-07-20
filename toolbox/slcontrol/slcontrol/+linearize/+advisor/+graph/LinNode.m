classdef LinNode<linearize.advisor.graph.AbstractLinNode
    properties
        JacobianBlockHandle double=[]
        ParentMdl double=[]
        IsMultiInstanced logical=false
        GraphicalBlockPath char=''
        GraphicalParentBlockHandles double=[]
        CompiledPortHandle double=[]
        Channel double=[]
        Port double=[]
        IsSynth logical=false
        OriginalBlock double=[]
    end
    methods
        function this=LinNode(type)
            this=this@linearize.advisor.graph.AbstractLinNode(type);
        end
        function idx=getInIOIdx(this)
            import linearize.advisor.graph.*
            types=[this.Type]';
            idx=ismember(types,[NodeTypeEnum.INLINIO]);
        end
        function jh=getOriginalJacobianHandle(this)
            if isempty(this.OriginalBlock)
                jh=this.JacobianBlockHandle;
            else
                jh=this.OriginalBlock;
            end
        end
        function[srcph,srcblk]=getModelSrc(this)
            ph=getPH(this);
            line=get_param(ph,'Line');
            srcph=[];
            srcblk=[];
            if~isempty(line)&&line>0


                try
                    srcph=get_param(line,'NonVirtualSrcPorts');
                catch
                    srcph=[];
                end
                if~isempty(srcph)
                    srcph=srcph(1);
                    srcblk=get_param(srcph,'Parent');
                end
            end
        end
        function ph=getPH(this)
            import linearize.advisor.graph.*
            jh=getOriginalJacobianHandle(this);
            if isempty(this.OriginalBlock)
                port=this.Port;
            else
                port=1;
            end
            if ishandle(jh)
                portHandles=get_param(jh,'PortHandles');
                switch this.Type
                case NodeTypeEnum.INCHANNEL
                    phs=getBlockPorts(portHandles,'inport');
                    ph=phs(port);
                case{NodeTypeEnum.OUTCHANNEL,NodeTypeEnum.INLINIO}

                    phs=getBlockPorts(portHandles,'outport');
                    ph=phs(port);
                case NodeTypeEnum.OUTLINIO

                    if strcmp(get_param(jh,'BlockType'),'Outport')
                        ph=portHandles.Inport(port);
                    else

                        phs=[portHandles.Outport,portHandles.State];
                        ph=phs(port);
                    end
                otherwise
                    ph=[];
                end
            else
                ph=[];
            end
        end
        function idx=getOutIOIdx(this)
            import linearize.advisor.graph.*
            types=[this.Type]';
            idx=ismember(types,[NodeTypeEnum.OUTLINIO]);
        end
        function str=getDataTipStr(this)
            str=getDataTipStr@linearize.advisor.graph.AbstractLinNode(this);
            if~isempty(this.Channel)
                str=sprintf(sprintf('%s%s: %u\n',str,'Channel',this.Channel));
            end
            if~isempty(this.Port)
                str=sprintf(sprintf('%s%s: %u\n',str,'Port',this.Port));
            end
        end
    end
    methods(Access=protected)
        function name=scalarprint(this)
            import linearize.advisor.graph.*
            node=this;
            blk=node.BlockPath;
            switch node.Type
            case NodeTypeEnum.BLOCK
                name=sprintf('b->%s',blk);
            case NodeTypeEnum.STATE
                name=sprintf('x%u->%s',node.Channel,blk);
            case NodeTypeEnum.OUTCHANNEL
                name=sprintf('y%u->%s',node.Channel,blk);
            case NodeTypeEnum.INCHANNEL
                name=sprintf('u%u->%s',node.Channel,blk);
            case NodeTypeEnum.OUTLINIO
                name=sprintf('Y%u->%s',node.Channel,blk);
            case NodeTypeEnum.INLINIO
                name=sprintf('U%u->%s',node.Channel,blk);
            end
        end
    end
end