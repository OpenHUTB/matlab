classdef CollapseEdgeType<fxptopo.internal.transformation.FilterEdgeType




    methods
        function wrapper=transform(this,wrapper)
            g=wrapper.Graph;
            locationOfEdges=find(g.Edges.Type==this.EdgeType);

            endNodes=g.Edges.EndNodes(locationOfEdges,:);%#ok<FNDSB>

            if~isempty(endNodes)
                endNode=endNodes(1,:);
                firstNode=endNode(1);
                secondNode=endNode(2);
                inEdgesToFirstNode=g.Edges.EndNodes(g.inedges(firstNode),:);
                outEdgesToSecondNode=g.Edges.EndNodes(g.outedges(secondNode),:);

                g=g.rmedge(firstNode,secondNode);

                nodesDrivingFirstNode=inEdgesToFirstNode(:,1);
                nodesDrivenBySecondNode=outEdgesToSecondNode(:,2);
                for iNode=1:numel(nodesDrivingFirstNode)
                    for jNode=1:numel(nodesDrivenBySecondNode)
                        if~findedge(g,nodesDrivingFirstNode(iNode),nodesDrivenBySecondNode(jNode))
                            edgeTable=table(fxptopo.internal.EdgeType.Connection,'VariableNames',{'Type'});
                            g=g.addedge(nodesDrivingFirstNode(iNode),nodesDrivenBySecondNode(jNode),edgeTable);
                        end
                    end
                end
                wrapper.Graph=g;

                wrapper=transform(this,wrapper);
            end
        end
    end
end
