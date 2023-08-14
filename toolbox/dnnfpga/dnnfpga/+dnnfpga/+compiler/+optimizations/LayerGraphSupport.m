classdef LayerGraphSupport




    methods(Static)
        function lgraphMerged=flattenIntoLayerGraph(layer,lgraphToBeMerged,lgraphOrig)
            import dnnfpga.compiler.optimizations.*
            import dnnfpga.dagCompile.*
            isSequential=isprop(layer,'OutputMode');
            lgraphMerged=lgraphOrig;
            for l=lgraphMerged.Layers'
                if Utils.cmpChars(layer.Name,l.Name)
                    for l=lgraphToBeMerged.Layers'
                        lgraphMerged=lgraphMerged.addLayers(l);
                    end
                    connections=lgraphToBeMerged.Connections;
                    for i=1:length(connections.Destination)
                        source=connections.Source{i};
                        dest=connections.Destination{i};
                        lgraphMerged=lgraphMerged.connectLayers(source,dest);
                    end
                    for i=1:numel(layer.InputNames)
                        inputName=layer.InputNames{i};


                        inputMerged=[layer.Name,'.',inputName];
                        dst0=layer.Name;
                        dst1=[layer.Name,'/',inputName];
                        edges0=LayerGraphSupport.getEdgesWithDst(dst0,lgraphMerged);
                        edges1=LayerGraphSupport.getEdgesWithDst(dst1,lgraphMerged);
                        edges2=LayerGraphSupport.getEdgesWithSrc(inputMerged,lgraphMerged);
                        edges=[edges0,edges1,edges2];
                        for edge=edges
                            lgraphMerged=lgraphMerged.disconnectLayers(edge.src,edge.dst);
                        end
                        lgraphMerged=lgraphMerged.removeLayers(inputMerged);
                        for edgeSrc=[edges0,edges1]
                            for edgeDst=edges2
                                lgraphMerged=lgraphMerged.connectLayers(edgeSrc.src,edgeDst.dst);
                            end
                        end
                    end
                    for i=1:numel(layer.OutputNames)
                        outputName=layer.OutputNames{i};


                        outputMerged=[layer.Name,'.',outputName];
                        src0=layer.Name;
                        src1=[layer.Name,'/',outputName];
                        edges0=LayerGraphSupport.getEdgesWithSrc(src0,lgraphMerged);
                        edges1=LayerGraphSupport.getEdgesWithSrc(src1,lgraphMerged);
                        edges2=LayerGraphSupport.getEdgesWithDst(outputMerged,lgraphMerged);
                        edges=[edges0,edges1,edges2];
                        for edge=edges
                            lgraphMerged=lgraphMerged.disconnectLayers(edge.src,edge.dst);
                        end
                        lgraphMerged=lgraphMerged.removeLayers(outputMerged);
                        lgraphMerged=lgraphMerged.removeLayers(layer.Name);
                        tsName=[layer.Name,'.','toSeq'];
                        tsName=layer.Name;

                        ts=dnnfpga.layer.labelLayer('Name',tsName);

                        lgraphMerged=lgraphMerged.addLayers(ts);
                        for edge=[edges0,edges1]
                            lgraphMerged=lgraphMerged.connectLayers(tsName,edge.dst);
                        end
                        for edge=edges2
                            lgraphMerged=lgraphMerged.connectLayers(edge.src,tsName);
                        end
                    end
                end
            end
        end
        function edges=getEdgesWithSrc(source,lgraph)
            import dnnfpga.dagCompile.*
            edges=[];
            connections=lgraph.Connections;
            for i=1:length(connections.Destination)
                src=connections.Source{i};
                dst=connections.Destination{i};
                if Utils.cmpChars(src,source)
                    e=struct();
                    e.src=src;
                    e.dst=dst;
                    edges=[edges,e];
                end
            end
        end
        function edges=getEdgesWithDst(dest,lgraph)
            import dnnfpga.dagCompile.*
            edges=[];
            connections=lgraph.Connections;
            for i=1:length(connections.Destination)
                src=connections.Source{i};
                dst=connections.Destination{i};
                if Utils.cmpChars(dst,dest)
                    e=struct();
                    e.src=src;
                    e.dst=dst;
                    edges=[edges,e];
                end
            end
        end


        function[layerCopy,changed]=copyLayer(layer)
            changed=false;
            switch(class(layer))
            case{'nnet.cnn.layer.FullyConnectedLayer'}
                layerCopy=fullyConnectedLayer(layer.OutputSize,'Name',layer.Name);
                layerCopy.Weights=layer.Weights;
                layerCopy.Bias=layer.Bias;
                changed=true;
            case{'nnet.cnn.layer.RegressionOutputLayer'}
                layerCopy=regressionLayer('Name',layer.Name);
                changed=true;
            case{'nnet.cnn.layer.WordEmbeddingLayer'}
                layerCopy=dnnfpga.layer.wordEmbeddingLayerDLP(layer);
                changed=true;
            otherwise
                layerCopy=layer;
            end
        end


        function lgraphUpdated=replaceLayer(lgraph,layer,name)

            if nargin<3
                name=layer.Name;
            end
            connections=lgraph.Connections;


            edges=[];
            for i=1:length(connections.Destination)
                src=connections.Source{i};
                dst=connections.Destination{i};
                edge=struct();
                edge.src=src;
                edge.dst=dst;
                edge.name=[src,'|',dst];
                edges=[edges,edge];
            end
            lgraphUpdated=lgraph.removeLayers(name);
            connections=lgraphUpdated.Connections;


            edgesAfter=[];
            for i=1:length(connections.Destination)
                src=connections.Source{i};
                dst=connections.Destination{i};
                edge=struct();
                edge.src=src;
                edge.dst=dst;
                edge.name=[src,'|',dst];
                edgesAfter=[edgesAfter,edge];
            end
            if~isempty(edgesAfter)
                diff=setdiff({edges.name},{edgesAfter.name});
            else
                diff={edges.name};
            end

            lgraphUpdated=lgraphUpdated.addLayers(layer);

            for label=diff
                both=strsplit(label{1},'|');
                lgraphUpdated=lgraphUpdated.connectLayers(both{1},both{2});
            end
        end

        function lgraphUpdated=removeLayer(lgraph,layer)
            import dnnfpga.dagCompile.*
            srcs={};
            dsts={};
            connections=lgraph.Connections;
            for i=1:length(connections.Destination)
                src=connections.Source{i};
                dst=connections.Destination{i};
                bothSrc=strsplit(src,'/');
                bothDst=strsplit(dst,'/');
                if Utils.cmpChars(bothSrc{1},layer.Name)
                    dsts{end+1}=dst;
                end
                if Utils.cmpChars(bothDst{1},layer.Name)
                    srcs{end+1}=src;
                end
            end
            lgraphUpdated=lgraph.removeLayers(layer.Name);
            for src=srcs
                for dst=dsts
                    lgraphUpdated=lgraphUpdated.connectLayers(src{1},dst{1});
                end
            end
        end
        function layer=getLayer(lgraph,name)
            import dnnfpga.dagCompile.*
            layer={};
            for l=lgraph.Layers'
                if Utils.cmpChars(l.Name,name)
                    layer=l;
                    break;
                end
            end
        end
        function lgraph=insertAfter(lgraph,layer,layerInsert)
            import dnnfpga.compiler.optimizations.*
            src0=layer.Name;
            src1=[layer.Name,'/',layer.OutputNames{1}];
            edges0=LayerGraphSupport.getEdgesWithSrc(src0,lgraph);
            edges1=LayerGraphSupport.getEdgesWithSrc(src1,lgraph);
            lgraph=lgraph.addLayers(layerInsert);
            edges=[edges0,edges1];
            for edge=edges
                lgraph=lgraph.disconnectLayers(edge.src,edge.dst);
            end
            for edge=edges
                lgraph=lgraph.connectLayers(edge.src,layerInsert.Name);
                lgraph=lgraph.connectLayers(layerInsert.Name,edge.dst);
            end
        end
        function lgraphCopy=copyLayerGraph(lgraph)
            lgraphCopy=layerGraph();
            for layer=lgraph.Layers'
                lgraphCopy.addLayers(layer);
            end
            connections=lgraph.Connections;
            for i=1:length(connections.Destination)
            end
        end

    end
end


