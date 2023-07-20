function outputs=allocateOutputMemory(obj,numOutputsRequested,outsizes,outputFormats,isInputSequenceVarsized)
















%#codegen



    coder.internal.prefer_const(numOutputsRequested,outsizes,outputFormats,isInputSequenceVarsized);
    coder.allowpcode('plain');
    coder.inline('always');

    out_type='single';


    outputs=cell(numOutputsRequested,1);

    coder.unroll();
    for outIdx=1:numOutputsRequested

        [isImageOutput,outputHasTimeDim]=coder.const(@coder.internal.dlnetwork.processOutputFormat,outputFormats{outIdx});

        if~outputHasTimeDim


            if isImageOutput
                new_outsize=...
                coder.internal.iohandling.cnn.OutputDataPreparer.getCevalImageOutputSize(outsizes{outIdx},obj.DLTargetLib);
            else

                new_outsize=permuteVectorOutsize(outsizes{outIdx});
            end

        else

            tmpOutSize=outsizes{outIdx};

            if isImageOutput

                if coder.isColumnMajor

                    permutationDims=coder.const([2,1,3:numel(outputFormats{outIdx})]);
                    new_outsize=tmpOutSize(permutationDims);

                    if isInputSequenceVarsized
                        featureSize=coder.const(new_outsize(1:end-1));

                        coder.varsize('outputs{outIdx}',[featureSize,Inf],[zeros(1,numel(featureSize)),1]);
                    end

                else

                    permutationDims=coder.const([numel(outputFormats{outIdx}):-1:3,1,2]);
                    new_outsize=tmpOutSize(permutationDims);

                    if isInputSequenceVarsized
                        featureSize=coder.const(new_outsize(2:end));

                        coder.varsize('outputs{outIdx}',[Inf,featureSize],[1,zeros(numel(featureSize),1)]);
                    end

                end


            else
                if coder.isColumnMajor

                    new_outsize=tmpOutSize;

                    if isInputSequenceVarsized
                        featureSize=coder.const(new_outsize(1:end-1));

                        coder.varsize('outputs{outIdx}',[featureSize,Inf],[zeros(1,numel(featureSize)),1]);
                    end

                else

                    permutationDims=coder.const(numel(outputFormats{outIdx}):-1:1);
                    new_outsize=tmpOutSize(permutationDims);

                    if isInputSequenceVarsized
                        featureSize=coder.const(new_outsize(2:end));

                        coder.varsize('outputs{outIdx}',[Inf,featureSize],[1,zeros(numel(featureSize),1)]);
                    end
                end
            end

        end


        outputs{outIdx}=coder.nullcopy(zeros(new_outsize,out_type));

    end

end

function new_outsize=permuteVectorOutsize(outsize)
    coder.inline('always');
    assert(numel(outsize)==2);
    if coder.isColumnMajor

        new_outsize=outsize;
    else

        tempSize=outsize;
        tempSize(1)=outsize(2);
        tempSize(2)=outsize(1);
        new_outsize=tempSize;
    end
end


