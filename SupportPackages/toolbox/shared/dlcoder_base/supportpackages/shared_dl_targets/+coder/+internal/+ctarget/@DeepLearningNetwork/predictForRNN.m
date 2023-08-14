%#codegen


function outputData=predictForRNN(obj,in,callerFunction,varargin)



    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;


    [miniBatchSize,sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection,returnCategorical]=...
    coder.internal.DeepLearningNetwork.parseInputsCodegenPredictRNN(varargin{:});

    [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder,outputFeatureSize,isImageOutput]=...
    coder.internal.DeepLearningNetwork.processInputSizeForPredictForRNN(obj,in,miniBatchSize,callerFunction,varargin);


    out=coder.internal.iohandling.rnn.OutputDataPreparer.prepareOutputForPredict(...
    in,outputFeatureSize,batchSize,isCellInput,isImageInput,isImageOutput,obj.HasSequenceOutput);









    if iscell(in)&&~coder.internal.isHomogeneousCell(in)
        coder.unroll();
    end

    for miniBatchIdx=1:numMiniBatches


        [miniBatch,sampleSequenceLengths]=obj.prepareMinibatchForRNN(in,obj.CodegenInputSizes{1}(1:3),...
        miniBatchSize,sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection,...
        isCellInput,isImageInput,miniBatchIdx,numMiniBatches,remainder,callerFunction);

        outMiniBatchC=cell(1,obj.NumOutputLayers);

        switch coder.const(callerFunction)
        case 'predict'

            outMiniBatchC=obj.callActivation({miniBatch},obj.OutputLayerIndices,...
            ones(1,obj.NumOutputLayers),obj.DLTNetwork,obj.NetworkInfo,obj.NetworkName,...
            obj.CodegenInputSizes,obj.InputLayerIndices);
        case{'predictAndUpdateState','classifyAndUpdateState'}
            outMiniBatchC=obj.callPredictAndUpdateState({miniBatch},miniBatchSize,...
            obj.DLTNetwork,obj.NetworkInfo,obj.NetworkName,obj.CodegenInputSizes,...
            obj.InputLayerIndices,obj.OutputLayerIndices,obj.NumOutputLayers);
        end
        outMiniBatch=outMiniBatchC{:};







        if(remainder>0)&&(miniBatchIdx==numMiniBatches)
            validSamples=remainder;
        else
            validSamples=miniBatchSize;
        end








        if~obj.HasSequenceOutput
            miniBatchOffset=miniBatchSize*(miniBatchIdx-1);
            if isCellInput






                permutedOutMiniBatch=permute(outMiniBatch,[3,2,1]);
                out(miniBatchOffset+(1:validSamples),:)=permutedOutMiniBatch(1,1:validSamples,:);
            else
                if isImageOutput



                    out=outMiniBatch;
                else

                    if numel(size(outMiniBatch))>2





                        out(miniBatchOffset+(1:validSamples),:)=permute(outMiniBatch,[4,3,1,2]);
                    else

                        outMiniBatchT=outMiniBatch';
                        out(miniBatchOffset+(1:validSamples),:)=outMiniBatchT(1:validSamples,:);
                    end
                end
            end
        else
            if isCellInput

                for sampleIdx=1:validSamples
                    outIndex=miniBatchSize*(miniBatchIdx-1)+sampleIdx;
                    reshapedSample=obj.prepareRNNCellOutput(...
                    outMiniBatch,outputFeatureSize,sampleSequenceLengths,sequenceLengthMode,...
                    sequencePaddingDirection,sampleIdx,isImageOutput);
                    out{outIndex}=reshapedSample;
                end
            else



                if isImageOutput


                    out=permute(outMiniBatch,[1,2,3,5,4]);
                else


                    out=permute(outMiniBatch,[1,3,2]);
                end
            end
        end
    end


    if coder.const(returnCategorical)

        outputDataCell=obj.postProcessOutputToReturnCategorical({out});


        outputData=outputDataCell{1};
    else
        outputData=out;
    end
end
