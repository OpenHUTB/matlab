classdef AbstractLinNode<linearize.advisor.graph.AbstractNode
    properties
        BlockPath char=''
        Name char=''
    end
    methods
        function str=getDataTipStr(this)

            pathstr=sprintf('%s: %s\n','Path',regexprep(this.BlockPath,'\n',' '));
            typestr=sprintf('%s: %s\n','Type',char(this.Type));
            str=[typestr,pathstr];
            if~isempty(this.Name)
                str=sprintf('%s%s: %s\n',str,'Name',this.Name);
            end
        end
    end
    methods(Access=protected)
        function this=AbstractLinNode(type)
            this.Type=type;
        end
    end
end