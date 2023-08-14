classdef MexDlnetworkLayer<nnet.internal.cnn.coder.MexNetworkLayer





    methods
        function obj=MexDlnetworkLayer(name,graph,mexNetwork)





            requestedOutputs=[mexNetwork.Config.LayerOutputIndices(:),mexNetwork.Config.LayerOutputPortIndices(:)];
            graph=graph.overrideOutputLocations(requestedOutputs);


            obj=obj@nnet.internal.cnn.coder.MexNetworkLayer(mexNetwork,name,graph);
        end


        function Z=predict(this,X)

            expectedPrecision=this.UnderlyingMexNetwork.Config.Precision;

            X=iWrapInCell(X);


            numInputs=numel(X);
            for i=1:numInputs
                currentX=X{i};




                data=extractdata(currentX);

                data=gpuArray(data);



                X{i}=cast(data,expectedPrecision);
            end


            Z=this.UnderlyingMexNetwork.predict(X);

            for i=1:numel(Z)

                Z{i}=gpuArray(Z{i});
            end
        end
    end
end

function X=iWrapInCell(X)
    if~iscell(X)
        X={X};
    end
end
