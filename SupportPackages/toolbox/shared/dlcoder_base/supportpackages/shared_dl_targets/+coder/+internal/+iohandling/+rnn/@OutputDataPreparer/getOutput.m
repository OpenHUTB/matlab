%#codegen





























function out=getOutput(dlTargetLib,outputFeatureSize,isSequenceOutput,isSequenceFolded,isCellInput,isImageInput,isImageOutput,miniBatchSize,sequenceLength,minibatch)




    coder.allowpcode('plain');





    coder.extrinsic('coder.internal.iohandling.rnn.OutputDataPreparer.getOutputFeatureSizeC');
    outputFeatureSizeC=coder.const(...
    @coder.internal.iohandling.rnn.OutputDataPreparer.getOutputFeatureSizeC,...
    coder.const(outputFeatureSize),...
    coder.const(isImageOutput),...
    coder.const(coder.isRowMajor));

    out_type='single';

    isSequenceLengthVarsize=iGetIsSequenceLengthVarsize(minibatch,miniBatchSize,isCellInput,isImageInput);
    if(isSequenceLengthVarsize)
        coder.internal.assert(~(strcmp(dlTargetLib,'cmsis-nn')),...
        'dlcoder_spkg:cnncodegen:VariableSequenceLength',...
        coder.const(dlTargetLib),'target');

    end





    if~isSequenceOutput&&~isSequenceFolded
        sequenceLength=1;
        isSequenceLengthVarsize=false;
    end

    if coder.isRowMajor
        if isCellInput

            opSize=[sequenceLength,miniBatchSize,outputFeatureSizeC];
            if isSequenceLengthVarsize

                coder.varsize('out',[Inf,miniBatchSize,outputFeatureSizeC],[1,0,zeros(1,numel(outputFeatureSizeC))]);
            end
        else

            opSize=[sequenceLength,outputFeatureSizeC];
            if isSequenceLengthVarsize

                coder.varsize('out',[Inf,outputFeatureSizeC],[1,zeros(1,numel(outputFeatureSizeC))]);
            end
        end

    else
        if isCellInput

            opSize=[outputFeatureSizeC,miniBatchSize,sequenceLength];
            if isSequenceLengthVarsize

                coder.varsize('out',[outputFeatureSizeC,miniBatchSize,Inf],[zeros(1,numel(outputFeatureSizeC)),0,1]);
            end

        else

            opSize=[outputFeatureSizeC,sequenceLength];
            if isSequenceLengthVarsize

                coder.varsize('out',[outputFeatureSizeC,Inf],[zeros(1,numel(outputFeatureSizeC)),1]);
            end

        end
    end

    out=coder.nullcopy(zeros(opSize,out_type));
end


function isSequenceLengthVarsize=iGetIsSequenceLengthVarsize(minibatch,miniBatchSize,isCellInput,isImageInput)
    coder.inline('always');

    if coder.isRowMajor








        isSequenceLengthVarsize=~coder.internal.isConst(size(minibatch,1));
    else
        if isCellInput
            if isImageInput


                isSequenceLengthVarsize=~coder.internal.isConst(size(minibatch,5));
            else
                if miniBatchSize==1





                    isSequenceLengthVarsize=~coder.internal.isConst(size(minibatch,2));
                else


                    isSequenceLengthVarsize=~coder.internal.isConst(size(minibatch,3));
                end
            end
        else
            if isImageInput


                isSequenceLengthVarsize=~coder.internal.isConst(size(minibatch,4));
            else


                isSequenceLengthVarsize=~coder.internal.isConst(size(minibatch,2));
            end
        end
    end
end
