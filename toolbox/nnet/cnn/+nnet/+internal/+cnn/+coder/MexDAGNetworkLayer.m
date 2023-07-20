classdef MexDAGNetworkLayer<nnet.internal.cnn.coder.MexNetworkLayer





    properties(Access=private)


        OutputAs2DRowResponses logical
    end


    methods
        function obj=MexDAGNetworkLayer(name,layerGraph,mexNetwork)
            obj=obj@nnet.internal.cnn.coder.MexNetworkLayer(mexNetwork,name,layerGraph);

            numOutputs=mexNetwork.Config.NumOutputs;


            outputAs2DRowResponses=false(numOutputs,1);
            if mexNetwork.Config.IsCallingPredict
                networkOutputs=obj.forwardExampleInputs(obj.InputData);
                for i=1:numOutputs
                    spatialOutputSize=getSizeForDims(networkOutputs{i},'S');
                    outputAs2DRowResponses(i)=all(spatialOutputSize==1);
                end
            end
            obj.OutputAs2DRowResponses=outputAs2DRowResponses;
        end
    end


    methods

        function Z=predict(this,X)

            numInputs=numel(this.InputSize);
            requiredBatchSize=this.UnderlyingMexNetwork.Config.MiniBatchSize;

            if numInputs>1
                X=iWrapInCell(X);



                [padAmount,inputBatchSize]=iGetRequiredPadAmount(X{1},requiredBatchSize);

                X={cellfun(@(x)iPadBatches(x,requiredBatchSize,padAmount,inputBatchSize),X,'UniformOutput',false)};
            else

                [padAmount,inputBatchSize]=iGetRequiredPadAmount(X,requiredBatchSize);
                X={iPadBatches(X,requiredBatchSize,padAmount,inputBatchSize)};
            end


            Z=this.UnderlyingMexNetwork.predict(X);
            Z=iWrapInCell(Z);

            for i=1:numel(Z)
                if padAmount>0



                    if this.OutputAs2DRowResponses(i)
                        Z{i}=Z{i}(1:inputBatchSize,:);
                    else
                        Z{i}=Z{i}(:,:,:,1:inputBatchSize);
                    end
                end
            end
        end








        function Z=activations(this,X,~,~)
            Z=predict(this,X);
            Z=Z{1};
        end

    end

end

function[padAmount,inputBatchSize]=iGetRequiredPadAmount(X,requiredBatchSize)



    inputBatchSize=size(X,4);

    padAmount=requiredBatchSize-inputBatchSize;
end

function Y=iPadBatches(X,requiredBatchSize,padAmount,inputBatchSize)








    if padAmount>0
        Y=zeros(size(X,1),size(X,2),size(X,3),requiredBatchSize,'like',X);
        Y(:,:,:,1:inputBatchSize)=X;
    else
        Y=X;
    end

end

function X=iWrapInCell(X)
    if~iscell(X)
        X={X};
    end
end