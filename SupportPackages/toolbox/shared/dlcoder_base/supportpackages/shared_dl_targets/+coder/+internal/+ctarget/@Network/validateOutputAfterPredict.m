function validateOutputAfterPredict(inputData,outputData,inputFormats,outputFormats,layer)


















%#codegen
    coder.allowpcode('plain')
    coder.internal.prefer_const(inputFormats,outputFormats);

    layerName=layer.Name;

    numOutputs=numel(outputFormats);

    coder.unroll()
    for iOut=1:numOutputs
        if isa(layer,'coder.internal.layer.SequenceFoldingLayer')
            iValidateOutputFolding(inputData,outputData,inputFormats,outputFormats,layerName,iOut);
        elseif isa(layer,'coder.internal.layer.SequenceUnfoldingLayer')
            assert(numOutputs==1,'Sequence unfolding should only have 1 output')
            iValidateOutputUnfolding(outputData,outputFormats{1},layerName);
        else
            iValidateOutputRestOfLayers(inputData,outputData,inputFormats,outputFormats,layerName,iOut);
        end
    end

end


function iValidateOutputFolding(X,Z,inputFormats,outputFormats,layerName,iOut)



    coder.inline('always')

    numOutputDims=numel(outputFormats{iOut});
    if coder.const(coder.internal.layer.utils.hasTimeDim(inputFormats{1}))

        numOutputDims=numOutputDims-1;
        if~coder.const(coder.internal.layer.utils.isDimensionConstant(X{1},inputFormats{1},'T'))


            if coder.const(coder.internal.layer.utils.hasBatchDim(inputFormats{1}))
                numOutputDims=numOutputDims-1;
            end
        end
    end
    checkNonVarsizeDims(Z,numOutputDims,layerName,iOut)
end

function iValidateOutputUnfolding(Z,outputFormats,layerName)


    coder.inline('always')


    numOutputDims=numel(outputFormats);
    if coder.const(coder.internal.layer.utils.hasTimeDim(outputFormats))
        numOutputDims=numOutputDims-1;
    end
    checkNonVarsizeDims(Z,numOutputDims,layerName,1)
end

function iValidateOutputRestOfLayers(X,Z,inputFormat,outputFormats,layerName,iOut)



    coder.inline('always')

    numOutputDims=numel(outputFormats{iOut});


    if coder.const(coder.internal.layer.utils.hasTimeDim(outputFormats{iOut}))
        numOutputDims=numOutputDims-1;
    end



    for iIn=1:numel(X)
        if coder.const(coder.internal.layer.utils.hasBatchDim(inputFormat{iIn}))
            if~coder.const(coder.internal.layer.utils.isDimensionConstant(X{iIn},inputFormat{iIn},'B'))

                numOutputDims=numOutputDims-1;
            end
        end
    end

    checkNonVarsizeDims(Z,numOutputDims,layerName,iOut)
end

function checkNonVarsizeDims(Z,numOutputDims,layerName,iOut)
    coder.unroll();
    for iDim=1:numOutputDims
        coder.internal.assert(coder.internal.isConst(size(Z{iOut},iDim)),...
        'dlcoder_spkg:cnncodegen:VariableOutputSizeDimension',iDim,iOut,layerName,...
        'IfNotConst','Fail');
    end
end
