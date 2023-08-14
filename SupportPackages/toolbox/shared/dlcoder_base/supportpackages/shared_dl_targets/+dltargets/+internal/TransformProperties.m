classdef TransformProperties<handle














































    properties(Access=private)
layerNameToIndexMap
layersDoNotFuse
ConvBatchnormFusedDLTLayerIdxMap
    end

    properties(SetAccess=immutable)
activationLayerIndices
    end


    methods


        function this=TransformProperties(networkInfo,activationLayerIndices)

            this.activationLayerIndices=activationLayerIndices;

            sortedLayerArray=networkInfo.SortedLayers;

            this.layerNameToIndexMap=containers.Map;
            for i=1:numel(sortedLayerArray)
                assert(~isempty(sortedLayerArray(i).Name));
                this.layerNameToIndexMap(sortedLayerArray(i).Name)=i;
            end

            if activationLayerIndices~=-1
                this.layersDoNotFuse={sortedLayerArray(activationLayerIndices).Name};
            else
                this.layersDoNotFuse=[];
            end



            this.ConvBatchnormFusedDLTLayerIdxMap=containers.Map;
        end


        function updateMap(this,convLayer,bnLayer)

            fusedDLTLayerIndices=[this.layerNameToIndexMap(convLayer.Name);this.layerNameToIndexMap(bnLayer.Name)];

            this.ConvBatchnormFusedDLTLayerIdxMap(convLayer.Name)=fusedDLTLayerIndices;


            this.layerNameToIndexMap(convLayer.Name)=this.layerNameToIndexMap(bnLayer.Name);


            remove(this.layerNameToIndexMap,bnLayer.Name);
        end


        function truth=isActivationLayer(this,layerName)
            truth=false;
            if~isempty(this.layersDoNotFuse)
                truth=any(strcmp(layerName,this.layersDoNotFuse));
            end
        end


        function idx=getLayerIdxFromMap(this,layer)
            idx=this.layerNameToIndexMap(layer.Name);
        end


        function map=getLayerNameToIndexMap(this)
            map=this.layerNameToIndexMap;
        end


        function indices=getLayersDoNotFuse(this)
            indices=this.layersDoNotFuse;
        end


        function fusedDLTLayerIndices=getConvBatchnormFusedDLTLayerIndices(this,convLayer)
            if isKey(this.ConvBatchnormFusedDLTLayerIdxMap,convLayer.Name)
                fusedDLTLayerIndices=this.ConvBatchnormFusedDLTLayerIdxMap(convLayer.Name);
            else

                fusedDLTLayerIndices=this.layerNameToIndexMap(convLayer.Name);
            end
        end

    end

end
