classdef FromSubGraphNodeInfo<internal.ml2pir.scope.NodeInfo






    properties(GetAccess=private,SetAccess=immutable)
        NodeInfoFromSubgraph(1,1)internal.ml2pir.scope.NodeInfo=...
        internal.ml2pir.scope.NodeInfo.unknownInfo;
        Name(1,:)char
GraphBuilder
SubGraphNode
    end

    properties(Access=private)
        OutputIdx(1,1)double=-1
    end

    methods(Access=public)

        function this=FromSubGraphNodeInfo(nodeInfo,name,builder,subGraphNode)
            this=this@internal.ml2pir.scope.NodeInfo([],nodeInfo.type);
            this.NodeInfoFromSubgraph=nodeInfo;
            this.Name=name;
            this.GraphBuilder=builder;
            this.SubGraphNode=subGraphNode;
        end

        function nd=node(this)
            if this.OutputIdx==-1


                this.GraphBuilder.setSubGraph(this.SubGraphNode);

                [newOutput,this.OutputIdx]=this.GraphBuilder.addOutput(this.Name,...
                internal.mtree.NodeTypeInfo(this.Type,[]));

                this.GraphBuilder.connect(this.NodeInfoFromSubgraph.node,newOutput);

                this.GraphBuilder.endSubGraph;
            end

            nd={this.SubGraphNode,this.OutputIdx};
        end

    end

end
