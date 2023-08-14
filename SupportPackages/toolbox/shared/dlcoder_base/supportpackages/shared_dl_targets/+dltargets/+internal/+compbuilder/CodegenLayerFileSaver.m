classdef CodegenLayerFileSaver<handle




    properties(Constant)
        WeightsFileNamePostfix='_w.bin';
        BiasFileNamePostfix='_b.bin';
        Precision='single';
    end

    properties(SetAccess=private)

NetworkInfo
TargetLibrary
    end

    properties(Access=private)

CodegenTarget


ParameterDirectory


RowMajorCustomLayerNames


CreateMethodArgsMap


ParameterFileNamesMap


FilePrefix


NetClassName
    end

    methods(Access=public)


        function obj=CodegenLayerFileSaver(networkInfo,codegenTarget,codegenDirectory,...
            rowMajorCustomLayerNames,netClassName,targetLibrary)
            obj.NetworkInfo=networkInfo;
            obj.CodegenTarget=codegenTarget;
            obj.ParameterDirectory=codegenDirectory;
            obj.RowMajorCustomLayerNames=rowMajorCustomLayerNames;
            obj.CreateMethodArgsMap=containers.Map;
            obj.ParameterFileNamesMap=containers.Map;
            obj.NetClassName=netClassName;
            obj.FilePrefix=strcat('cnn_',netClassName,'_');
            obj.TargetLibrary=targetLibrary;
        end

        function saveFiles(obj)
            layers=getLayers(obj);



            [status,msg]=mkdir(obj.ParameterDirectory);
            assert(status,msg);

            for i=1:numel(layers)
                dltargets.internal.compbuilder.CodegenCompBuilder.doSaveFiles(layers(i),obj);
            end
        end



        function layers=getLayers(obj)
            layers=obj.NetworkInfo.SortedLayers;
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

        function codegenTarget=getCodegenTarget(obj)
            codegenTarget=obj.CodegenTarget;
        end

        function parameterDirectory=getParameterDirectory(obj)
            parameterDirectory=obj.ParameterDirectory;
        end

        function rowMajorCustomLayerNames=getRowMajorCustomLayerNames(obj)
            rowMajorCustomLayerNames=obj.RowMajorCustomLayerNames;
        end

        function createMethodArgsMap=getCreateMethodArgsMap(obj)
            createMethodArgsMap=obj.CreateMethodArgsMap;
        end

        function parameterFileNamesMap=getParameterFileNamesMap(obj)
            parameterFileNamesMap=obj.ParameterFileNamesMap;
        end

        function filePrefix=getFilePrefix(obj)
            filePrefix=obj.FilePrefix;
        end

        function netClassName=getNetClassName(obj)
            netClassName=obj.NetClassName;
        end


        function obj=setParameterFileNamesMap(obj,layerName,val)
            obj.ParameterFileNamesMap(layerName)=val;
        end

        function obj=setCreateMethodArgsMap(obj,layerName,val)
            obj.CreateMethodArgsMap(layerName)=val;
        end

    end

end
