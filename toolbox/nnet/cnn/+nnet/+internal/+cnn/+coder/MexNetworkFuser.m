classdef MexNetworkFuser<nnet.internal.cnn.dlnetwork.optimization.Fuser





    properties(SetAccess=protected)
        SupportsTraining=false
        SupportsUpdate=false
    end

    properties(Access=private)

MexNetwork


NumberOfLayers
    end

    methods
        function obj=MexNetworkFuser(mexNetwork)



            obj.MexNetwork=mexNetwork;
        end

        function matchesInfo=findMatches(~,layerGraph)

            indices=(1:numel(layerGraph.Layers));
            matchesInfo=nnet.internal.cnn.dlnetwork.optimization.MatchInfo(indices);
        end

        function fusedLayer=fuseSubgraph(this,subgraph,~,~)

            fusedLayerFcn=this.MexNetwork.Config.getFusedLayerFcn();
            defaultName=nnet.internal.cnn.coder.MexNetworkLayer.DefaultName;
            fusedLayer=fusedLayerFcn(defaultName,subgraph,this.MexNetwork);
        end
    end
end


