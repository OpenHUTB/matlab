classdef NodeInfo<handle




    properties(GetAccess=protected,SetAccess=immutable)
Node
        Type(1,1)internal.mtree.Type=internal.mtree.type.UnknownType;
    end

    methods(Access=public)

        function this=NodeInfo(node,nodeType)
            this.Node=node;
            this.Type=nodeType;
        end

        function nd=node(this)
            nd=this.Node;
        end

        function tp=type(this)
            tp=this.Type;
        end

    end

    methods(Static,Access=public)
        function nodeInfo=unknownInfo()
            nodeInfo=internal.ml2pir.scope.NodeInfo([],internal.mtree.type.UnknownType);
        end
    end

end
