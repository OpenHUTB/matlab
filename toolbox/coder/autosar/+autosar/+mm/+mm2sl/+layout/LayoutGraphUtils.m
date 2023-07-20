classdef LayoutGraphUtils<handle





    methods(Static)










        function layers=getLayoutLayers(srcNodes,dstNodes,leafNodes)
            assert(iscell(srcNodes),'srcNodes must be cell array');
            assert(iscell(dstNodes),'srcNodes must be cell array');
            assert(iscell(leafNodes),'srcNodes must be cell array');


            assert(numel(srcNodes)==numel(dstNodes),...
            'srcNodes and dstNodes must contain the same number of nodes.');


            layers={};
            if~isempty(leafNodes)
                layers={leafNodes};
            end

            if isempty(srcNodes)

                return;
            end


            diG=autosar.mm.mm2sl.layout.LayoutGraphUtils.createDiGraph(srcNodes,dstNodes);



            mlG=MLDigraph(diG);
            [~,~,orderedLayers]=layeredLayout(mlG,[],[],'auto');




            numericNodeToStringNodeMap=containers.Map(mlG.Edges(1:end),...
            diG.Edges.EndNodes(1:end));

            for orderIdx=1:length(orderedLayers)
                layerNodesNumeric=orderedLayers{orderIdx};
                layerNodesString=[];
                for elmIdx=1:length(layerNodesNumeric)
                    key=layerNodesNumeric(elmIdx);
                    if numericNodeToStringNodeMap.isKey(key)
                        layerNodesString{end+1}=numericNodeToStringNodeMap(key);%#ok<AGROW>
                    end
                end
                orderedLayers{orderIdx}=flip(layerNodesString);
            end

            if~isempty(layers)
                layers=[layers,orderedLayers];
            else
                layers=orderedLayers;
            end
        end


        function plotDiGraphLayered(G)
            args={'Layout','layered','Direction','right'};
            if any(strcmp(G.Edges.Properties.VariableNames,'Weight'))
                args=[args,{'EdgeLabel',G.Edges.Weight}];
            end
            plot(G,args{:});
        end
    end

    methods(Static,Access=private)




        function G=createDiGraph(srcNodes,dstNodes)
            assert(iscell(srcNodes),'srcNodes must be cell array');
            assert(iscell(dstNodes),'srcNodes must be cell array');

            assert(numel(srcNodes)==numel(dstNodes),...
            'srcNodes and dstNodes must contain the same number of nodes.');

            G=digraph();
            for nodeIdx=1:length(srcNodes)
                srcNode=srcNodes{nodeIdx};
                dstNode=dstNodes{nodeIdx};

                if G.numnodes>0
                    if(G.findnode(srcNode)~=0)&&(G.findnode(dstNode)~=0)


                        edge=G.findedge(srcNode,dstNode);
                        if(edge~=0)

                            G.Edges.Weight(edge)=G.Edges.Weight(edge)+1;
                        else

                            G=G.addedge(srcNode,dstNode,1);
                        end
                    else

                        G=G.addedge(srcNode,dstNode,1);
                    end
                else

                    G=G.addedge(srcNode,dstNode,1);
                end
            end
        end
    end
end
