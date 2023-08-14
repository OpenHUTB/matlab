classdef CustomLayerClassConverter<handle




    properties

Layers


LayerComps


NetworkInfo




BuildContext


TargetLib





QuantizationSpecification


FiMathObject
    end

    methods(Access=public)


        function obj=CustomLayerClassConverter(layerComps,networkInfo,buildContext,quantizationSpec,targetLib)







            obj.Layers=networkInfo.OriginalSortedLayerGraph.Layers;
            obj.LayerComps=layerComps;
            obj.NetworkInfo=networkInfo;
            obj.BuildContext=buildContext;
            obj.QuantizationSpecification=quantizationSpec;
            obj.TargetLib=targetLib;

            if~isempty(quantizationSpec)


                obj.FiMathObject=fimath('OverflowAction','Wrap','RoundingMethod','Convergent');
            end


            assert(strcmp(targetLib,'none'));
        end

        function customLayerArray=doit(obj)
            numLayerComps=numel(obj.LayerComps);
            for iLayer=numLayerComps:-1:1
                customLayerArray(iLayer,1)=coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.doConvert...
                (obj.LayerComps(iLayer),obj);
            end
        end

        function layerInfo=getLayerInfo(obj,layerName)
            layerInfo=obj.NetworkInfo.LayerInfoMap(layerName);
        end

        function batchSize=getBatchSize(obj)
            batchSize=obj.NetworkInfo.BatchSize;
        end
    end
end
