classdef helperReweightLayer<nnet.layer.Layer


    properties

        LearnableParameters=nnet.internal.cnn.layer.learnable.PredictionLearnableParameter.empty();
        weightL=1;
        featureL=2;
    end

    properties(Constant)

        DefaultName='reweight'
    end


    methods
        function this=helperReweightLayer(name)
            this.Name=name;
            this.NumInputs=2;
            this.Description='rewights the feature maps';




        end

        function Z=predict(this,X,Y)







            Z=X.*Y;








        end


        function[dX,dY]=backward(this,X,Y,Z,dLdZ,memory)
















            if(size(Y,1)==1)
                dX=Y.*dLdZ;
                dY=sum(sum(X.*dLdZ));
                dW=[];
            else
                dY=X.*dLdZ;
                dX=sum(sum(Y.*dLdZ));
                dW=[];
            end
        end
    end
end