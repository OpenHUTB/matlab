



classdef BlockGraph<handle
    properties(SetAccess=protected,GetAccess=public)
Model
Blocks
Graph
VertexMap
    end


    methods(Static,Access=public)
        function g=create(blocks)
            g=Simulink.ModelReference.BlockGraph(Simulink.ModelReference.Conversion.Utilities.getHandles(blocks));
        end
    end


    methods(Access=public)
        function removeVertexes(this,vids)
            if~isempty(vids)
                g=this.Graph;


                arrayfun(@(aNode)this.removeBranch(g,aNode),vids);


                allKeys=this.VertexMap.keys;
                allValues=this.VertexMap.values;
                this.VertexMap.remove(allKeys(cellfun(@(v)~g.isVertex(v),allValues)));
            end
        end
    end


    methods(Access=protected)
        function this=BlockGraph(blocks)
            this.Model=bdroot(blocks(1));
            this.Blocks=blocks;
            this.Graph=matlab.internal.container.graph.Graph('Directed',true);
            this.VertexMap=containers.Map('KeyType','double','ValueType','uint64');
            this.build;
        end


        function build(this)
            numberOfBlocks=length(this.Blocks);


            v=struct('ID',this.Model,'Type','BlockDiagram','Commented',false);
            vid=this.Graph.addVertex(v);
            this.VertexMap(this.Model)=vid;


            for idx=1:numberOfBlocks
                currentBlock=this.Blocks(idx);
                childBlock=[];
                while(true)
                    if(this.VertexMap.isKey(currentBlock))
                        if~isempty(childBlock)
                            addEdge(this.Graph,this.VertexMap(currentBlock),this.VertexMap(childBlock));
                        end
                        break;
                    else
                        vid=addVertex(this.Graph,this.getBlockInfo(currentBlock));
                        this.VertexMap(currentBlock)=vid;
                        if~isempty(childBlock)
                            currentVId=this.VertexMap(currentBlock);
                            childVId=this.VertexMap(childBlock);
                            if~isEdge(this.Graph,[currentVId,childVId])
                                addEdge(this.Graph,currentVId,childVId);
                            end
                        end


                        childBlock=currentBlock;
                        currentBlock=get_param(get_param(currentBlock,'Parent'),'Handle');
                    end
                end
            end
        end
    end


    methods(Static,Access=protected)
        function v=getBlockInfo(currentBlock)
            v=struct('ID',currentBlock,...
            'Type',get_param(currentBlock,'BlockType'),...
            'Commented',~strcmpi(get_param(currentBlock,'Commented'),'off'));
        end

        function removeBranch(g,vid)
            if g.isVertex(vid)
                g.removeVertex(g.depthFirstTraverse(vid));
            end
        end
    end
end
