classdef CodegenLayerValidator<handle




    properties


layers


layerInfoMap


inputNames


dlcfg


isCnnCodegenWorkflow

    end

    properties(Access=private)
        ErrorHandler(1,1)


net
    end


    methods(Access=public)


        function obj=CodegenLayerValidator(net,dlcfg,layerInfoMap,isCnnCodegenWorkflow,errorHandler)

            obj.net=net;

            obj.layers=iReplaceLayersWithRedirectedLayers(net.Layers);

            obj.layerInfoMap=layerInfoMap;

            obj.inputNames=net.InputNames;

            obj.dlcfg=dlcfg;

            obj.isCnnCodegenWorkflow=isCnnCodegenWorkflow;

            obj.ErrorHandler=errorHandler;

        end


        function validate(obj)
            for i=1:numel(obj.layers)
                dltargets.internal.compbuilder.CodegenCompBuilder.doValidate(obj.layers(i),obj);
            end
        end

    end

    methods(Sealed)

        function net=getNetwork(obj)
            net=obj.net;
        end

        function targetLib=getTargetLib(obj)
            targetLib=obj.dlcfg.TargetLibrary;
        end

        function inputLayers=getInputLayers(obj)
            inputLayers=obj.layers(ismember({obj.layers.Name},obj.inputNames));
        end

        function layerInfo=getLayerInfo(obj,layerName)
            layerInfo=obj.layerInfoMap(layerName);
        end

        function handleError(obj,layer,errorMsg)
            obj.ErrorHandler.handleLayerError(layer,errorMsg);
        end
    end
end

function layers=iReplaceLayersWithRedirectedLayers(layers)
    layers=dltargets.internal.utils.NetworkUtils.replaceLayersWithRedirectedLayers(layers);
end
