classdef FullyConnectedLayer<nnet.layer.Layer





































%#codegen


    properties
        Weights;
        Bias;
    end

    properties(Access=private,Hidden=true)
        OutputFormat;
        InputFormat;
    end

    methods
        function layer=FullyConnectedLayer(name,Weights,Bias,inputFormat,outputFormat)
            layer.Name=name;
            layer.Type='FullyConnected';
            layer.Description='Fully connected';
            layer.Weights=Weights;
            layer.Bias=Bias;
            layer.OutputFormat=outputFormat;
            layer.InputFormat=inputFormat;
        end

        function Z=predict(layer,X)
            coder.allowpcode('plain');


            isNumSpatialDimsSupported=coder.const(coder.internal.layer.utils.numSpatialDims(layer.InputFormat)==2||...
            coder.internal.layer.utils.numSpatialDims(layer.InputFormat)==0);
            coder.internal.assert(isNumSpatialDimsSupported,'Coder:builtins:Explicit',...
            'If the input format for FullyConnectedLayer has spatial dimensions ''S'', it is expected to have two of them');


            layerOutput=coder.internal.layer.fullyConnectedForward(layer,X);
            inputBatchDim=coder.const(@feval,'strfind',layer.InputFormat,'B');
            inputSequenceDim=coder.const(@feval,'strfind',layer.InputFormat,'T');


            if coder.const(coder.internal.layer.utils.hasTwoSpatialDims(layer.InputFormat))
                if coder.const(~coder.internal.layer.utils.hasTimeDim(layer.InputFormat))

                    if coder.internal.layer.utils.hasTwoSpatialDims(layer.OutputFormat)

                        Z=reshape(layerOutput,1,1,size(layerOutput,1),size(layerOutput,2));
                    else

                        Z=layerOutput;
                    end
                else

                    if coder.const(~isempty(inputBatchDim))



                        Z=reshape(layerOutput,size(layerOutput,1),size(X,inputBatchDim),size(X,...
                        inputSequenceDim));
                    else



                        Z=reshape(layerOutput,size(layerOutput,1),size(X,inputSequenceDim));
                    end
                end
            else

                if coder.const(~coder.internal.layer.utils.hasTimeDim(layer.InputFormat))

                    Z=layerOutput;
                else

                    if coder.const(~isempty(inputBatchDim))



                        Z=reshape(layerOutput,size(layerOutput,1),size(X,inputBatchDim),size(X,...
                        inputSequenceDim));
                    else



                        Z=reshape(layerOutput,size(layerOutput,1),size(X,inputSequenceDim));
                    end
                end
            end
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'InputFormat','OutputFormat'};
        end
    end
end
