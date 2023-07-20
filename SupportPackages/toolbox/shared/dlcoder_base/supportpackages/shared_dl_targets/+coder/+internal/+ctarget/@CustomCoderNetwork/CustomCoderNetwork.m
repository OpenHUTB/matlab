%#codegen



classdef CustomCoderNetwork





    properties(Access=private)


NumLayers


NumStatefulLayers


InputConnections




InputLayerIndices


IsStateful


StatefulIdx


FusedLayersMap






IsFusedLayerMap



LayerInfoMap



LayerToPropertyFilesMap





OptimizedLayerGraph
    end

    properties(Dependent,Access=private)

Layers
    end

    methods(Hidden=true)


        function obj=CustomCoderNetwork(net,networkName,networkInfo,buildContext)
            coder.allowpcode('plain');

            quantizationSpecification=deep.internal.quantization.getQuantizationInfoComposite(net);


            activationLayerIndices=-1;

            transformProperties=dltargets.internal.TransformProperties(networkInfo,...
            activationLayerIndices);

            dlConfig=coder.const(@feval,...
            'coder.internal.getDeepLearningConfig',buildContext,"none");


            networkInfo=dltargets.internal.optimizations.optimizeNetwork(networkInfo,...
            dlConfig,transformProperties);


            buildDirectory=coder.internal.ctarget.CustomCoderNetwork.getBuildDirectory(buildContext,...
            dlConfig);


            layerComps=coder.internal.ctarget.CustomCoderNetwork.buildAndOptimizePIR(networkInfo,...
            networkName,buildContext,dlConfig,transformProperties,buildDirectory);


            layerGraphWithCustomLayers=...
            coder.internal.ctarget.CustomCoderNetwork.createLayerGraphWithCustomLayers(layerComps,...
            networkInfo,buildContext,quantizationSpecification);



            dltargets.internal.deleteWeightFiles(buildDirectory);


            [fusedLayersMap,isFusedLayerMap]=coder.internal.ctarget.CustomCoderNetwork.createFusedLayersMap(layerComps);

            updateNetworkInfoPostFusion(networkInfo,layerGraphWithCustomLayers,fusedLayersMap,layerComps);


            layerProperties=coder.internal.ctarget.CustomCoderNetwork.parseNetwork(layerGraphWithCustomLayers);


            obj.LayerToPropertyFilesMap=...
            coder.internal.ctarget.CustomCoderNetwork.createLayerToPropertyFilesMap(...
            layerGraphWithCustomLayers,networkName,buildContext.BuildDir);



            dltargets.internal.NetworkFileSaver.generateNetworkInfoFileForUnsupportedTargets(networkName,...
            buildDirectory,buildContext.CodeGenTarget,'none');

            obj.InputLayerIndices=...
            coder.internal.ctarget.CustomCoderNetwork.setInputLayerIndices(networkInfo);


            obj.OptimizedLayerGraph=layerGraphWithCustomLayers;
            obj.NumLayers=layerProperties.numLayers;
            obj.NumStatefulLayers=layerProperties.numStatefulLayers;
            obj.InputConnections=layerProperties.inputConnections;
            obj.IsStateful=layerProperties.isStateful;
            obj.StatefulIdx=layerProperties.statefulIdx;
            obj.FusedLayersMap=coder.const(fusedLayersMap);
            obj.IsFusedLayerMap=coder.const(isFusedLayerMap);
            obj.LayerInfoMap=networkInfo.LayerInfoMap;
        end

    end

    methods(Static)


        layerProperties=parseNetwork(layerGraph);


        buildDirectory=getBuildDirectory(buildContext,dlConfig)


        layerGraphWithCustomLayers=createLayerGraphWithCustomLayers(pirLayerComps,...
        networkInfo,buildContext,quantizationSpecification);

        inputLayerIndices=...
        setInputLayerIndices(networkInfo);


        [fusedLayersMap,isFusedLayerMap]=createFusedLayersMap(layerComps,networkInfo);


        layerComps=buildAndOptimizePIR(networkInfo,networkName,buildContext,dlConfig,...
        transformProperties,buildDirectory);


        connections=getConnectionsFromPIRComps(layerComps);



        propertiesAndFiles=saveLayerPropertiesToFile(layer,networkName,buildDirectory);
        LayerToPropertyFilesMap=createLayerToPropertyFilesMap(layerGraph,networkName,buildDirectory);
    end

    methods(Access=public)

        [fusedIndices,fusedLayerOffsetIndices]=getFusedLayerIndices(obj,layerIndices);

        isActivationLayerFused=hasFusedActivationLayers(obj,activationLayerIndices);

        activationsNeedReshapeBool=checkIfActivationsNeedReshape(obj,fusedActivationLayerIndices);

        [layerInputFormats,layerOutputFormats]=getLayerIOFormats(obj,layerIndices,networkInfo)

        propertiesToFile=getLayerToPropertyFiles(obj,layerName);

        function numStatefulLayers=getNumStatefulLayers(obj)
            numStatefulLayers=obj.NumStatefulLayers;
        end

        function numLayers=getNumLayers(obj)
            numLayers=obj.NumLayers;
        end

        function layer=getLayer(obj,idx)
            layer=obj.Layers(idx);
        end

        function optimizedLayerGraph=getOptimizedLayerGraph(obj)
            optimizedLayerGraph=obj.OptimizedLayerGraph;
        end

        function inputLayerIndices=getInputLayerIndices(obj)
            inputLayerIndices=obj.InputLayerIndices;
        end

        function layer=getLayerInputConnections(obj,idx)
            layer=obj.InputConnections{idx};
        end

        function flag=isStatefulLayer(obj,idx)
            flag=obj.IsStateful(idx);
        end

        function index=getStatefulIdx(obj,idx)
            index=obj.StatefulIdx(idx);
        end

        function[layers,statefulIdx]=getStatefulLayers(obj)
            layers=obj.Layers(obj.IsStateful);
            statefulIdx=obj.StatefulIdx(obj.IsStateful);
        end

        function flag=isLayerInputSequenceData(obj,layerName)
            layerInfo=obj.LayerInfoMap(layerName);
            flag=layerInfo.hasSequenceInput;
        end

        function[hasDlarrayInputs,inputFormats,outputFormats]=getDlarrayProperties(obj,layerName)
            layerInfo=obj.LayerInfoMap(layerName);
            hasDlarrayInputs=layerInfo.hasDlarrayInputs;
            inputFormats=layerInfo.inputFormats;
            outputFormats=layerInfo.outputFormats;
        end

        function numLayers=getNumTunableLayers(obj)
            numLayers=numel(keys(obj.LayerToPropertyFilesMap));
        end

        function numLayers=getNumNonTunableLayers(obj)
            numLayers=obj.NumLayers-getNumTunableLayers(obj);
        end
    end

    methods
        function layers=get.Layers(obj)
            layers=obj.OptimizedLayerGraph.Layers;
        end
    end
end


