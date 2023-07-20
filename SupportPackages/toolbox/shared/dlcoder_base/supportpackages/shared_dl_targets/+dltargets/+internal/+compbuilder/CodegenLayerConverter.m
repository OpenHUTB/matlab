classdef CodegenLayerConverter<handle




    properties

layers


layerToCompMap


targetLib


hN


netClassName


NetworkInfo


transformProperties



customLayerClassMap


layerHeaders


FileSaver
    end

    methods(Access=public)

        function obj=CodegenLayerConverter(networkInfo,...
            hN,netClassName,transformProperties,...
            targetLib,codegenTarget,codegenDir,...
            rowMajorCustomLayerNames)

            obj.layers=networkInfo.SortedLayers;

            obj.targetLib=targetLib;
            obj.hN=hN;
            obj.netClassName=netClassName;
            obj.NetworkInfo=networkInfo;
            obj.transformProperties=transformProperties;
            obj.customLayerClassMap=containers.Map;
            obj.layerHeaders=dltargets.internal.SupportedLayers.m_headerFiles;
            obj.layerToCompMap=containers.Map;

            obj.FileSaver=dltargets.internal.compbuilder.CodegenLayerFileSaver(networkInfo,...
            codegenTarget,codegenDir,rowMajorCustomLayerNames,netClassName,targetLib);
        end

        function layerToCompMap=convert(obj)


            obj.FileSaver.saveFiles();


            for i=1:numel(obj.layers)
                dltargets.internal.compbuilder.CodegenCompBuilder.doConvert(obj.layers(i),obj);
            end

            layerToCompMap=obj.layerToCompMap;
        end

        function inputLayerSizes=getInputLayerSizes(obj)
            inputLayerSizes=obj.NetworkInfo.InputLayerSizes;
        end

        function codegenInputSizes=getCodegenInputSizes(obj)
            codegenInputSizes=obj.NetworkInfo.CodegenInputSizes;
        end

        function inputLayers=getInputLayers(obj)
            inputLayers=obj.NetworkInfo.InputLayers;
        end

        function layerInfo=getLayerInfo(obj,layerName)
            layerInfo=obj.NetworkInfo.getLayerInfo(layerName);
        end

        function parameterFileNames=getParameterFileNames(obj,layerName)
            parameterFileNamesMap=obj.FileSaver.getParameterFileNamesMap;
            if isKey(parameterFileNamesMap,layerName)
                parameterFileNames=parameterFileNamesMap(layerName);
            else
                parameterFileNames=[];
            end
        end

        function createMethodArgs=getCreateMethodArgs(obj,layerName)
            createMethodArgsMap=obj.FileSaver.getCreateMethodArgsMap;
            if isKey(createMethodArgsMap,layerName)
                createMethodArgs=createMethodArgsMap(layerName);
            else
                createMethodArgs=[];
            end
        end

        function index=getSourceDLTLayerIndex(obj,layer)
            allNames=string({obj.NetworkInfo.OriginalSortedLayerGraph.Layers.Name});
            layerName=layer.Name;
            originalLayerIndices=layerName==allNames;
            index=find(originalLayerIndices);
            assert(numel(index)==1,"Expected to find only one layer");
        end

    end

end
