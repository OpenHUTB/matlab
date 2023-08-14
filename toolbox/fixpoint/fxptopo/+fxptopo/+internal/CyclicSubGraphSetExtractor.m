classdef CyclicSubGraphSetExtractor







    properties(SetAccess=private)
        Graph digraph=digraph
        NodeSet cell
        SubGraphs cell
    end

    methods
        function this=extract(this,diGraphObject)
            this.Graph=diGraphObject;


            c=conncomp(diGraphObject,'Type','strong');
            u=unique(c);
            nodeSet={};
            subGraphs={};
            for ii=u
                nodes=find(c==ii);
                subGraph=subgraph(diGraphObject,nodes);
                if~isdag(subGraph)
                    nodeSet{end+1}=nodes;%#ok<AGROW>
                    subGraphs{end+1}=subGraph;%#ok<AGROW>
                end
            end
            this.NodeSet=nodeSet;
            this.SubGraphs=subGraphs;
        end
    end
end
