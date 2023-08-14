classdef SimscapeNode<linearize.advisor.graph.AbstractLinNode
    properties
        Description char=''
        Index double=[]
        OPVal double=[]
    end
    methods
        function this=SimscapeNode(type)
            this@linearize.advisor.graph.AbstractLinNode(type);
        end
        function str=getDataTipStr(this)
            str=getDataTipStr@linearize.advisor.graph.AbstractLinNode(this);
            str=sprintf(sprintf('%s%s: %u\n',str,'Index',this.Index));
            if~isempty(this.Description)
                str=sprintf('%s%s: %s\n',str,'Description',this.Description);
            end
            if~isempty(this.OPVal)
                if this.Type==linearize.advisor.graph.NodeTypeEnum.SIMSCAPE_INPUT
                    optype='u';
                else
                    optype='x';
                end
                str=sprintf(sprintf('%s%s: %.3f\n',str,optype,this.OPVal));
            end
        end
    end
    methods(Access=protected)
        function name=scalarprint(this)
            import linearize.advisor.graph.*
            node=this;
            name=node.Name;
            i=node.Index;
            switch node.Type
            case NodeTypeEnum.SIMSCAPE_INPUT
                name=sprintf('u%u',i);
            case NodeTypeEnum.SIMSCAPE_OUTPUT
                name=sprintf('y%u',i);
            case NodeTypeEnum.SIMSCAPE_DIFFERENTIAL
                name=sprintf('x%u',i);
            case NodeTypeEnum.SIMSCAPE_DERIVATIVE
                name=sprintf('dx%u',i);
            case NodeTypeEnum.SIMSCAPE_ALGEBRAIC
                name=sprintf('a%u',i);
            end
        end
    end
end