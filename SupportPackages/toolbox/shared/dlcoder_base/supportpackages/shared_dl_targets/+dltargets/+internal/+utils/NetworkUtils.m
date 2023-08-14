classdef NetworkUtils<handle






    methods(Static)

        function lgraph=getLayerGraph(net)

            if isa(net,'DAGNetwork')||isa(net,'dlnetwork')
                lgraph=layerGraph(net);
            else
                assert(isa(net,'SeriesNetwork'));
                lgraph=layerGraph(net.Layers);

            end

        end

        function edgeTable=getEdgeTable(edgeList,portList)













            numRows=size(portList,1);
            portList=mat2cell(portList,ones(1,numRows));
            edgeTable=table(edgeList,portList,'VariableNames',{'EndNodes','EndPorts'});
        end


        function lgraphOrLayers=replaceLayersWithRedirectedLayers(lgraphOrLayers)

            if isa(lgraphOrLayers,'nnet.cnn.LayerGraph')
                for i=1:numel(lgraphOrLayers.Layers)
                    layer=lgraphOrLayers.Layers(i);
                    if coder.internal.hasPublicStaticMethod(class(layer),'matlabCodegenRedirect')
                        redirectedLayer=coder.internal.toRedirected(layer);
                        lgraphOrLayers=lgraphOrLayers.replaceLayer(layer.Name,redirectedLayer);
                    end
                end

            else
                for i=1:numel(lgraphOrLayers)
                    layer=lgraphOrLayers(i);
                    lgraphOrLayers(i)=coder.internal.toRedirected(layer);
                end

            end
        end

    end

end
