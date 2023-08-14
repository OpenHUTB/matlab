%#codegen


function callPredictForCustomLayers(obj,miniBatchSequenceLengthValue)





    coder.inline('never');
    coder.allowpcode('plain');


    coder.ceval(obj.callPredictForCustomLayersAnchor,coder.wref(obj.anchor));


    if obj.IsRNN
        isFixedSizeInput=coder.internal.isConst(miniBatchSequenceLengthValue);
    else
        isFixedSizeInput=true;

    end

    for layerIdx=coder.unroll(1:obj.CustomLayerProperties.numCustomLayers)

        inputSizes=obj.CustomLayerProperties.inputSizes{layerIdx};
        inputFormats=obj.CustomLayerProperties.inputFormats{layerIdx};
        hasSequenceInputs=obj.CustomLayerProperties.hasSequenceInput{layerIdx};

        numInputs=numel(inputSizes);
        inC=cell(1,numInputs);
        dataInSz=cell(1,numInputs);

        for inIdx=1:numInputs



            if coder.const(hasSequenceInputs(inIdx))
                sequenceLengthValue=miniBatchSequenceLengthValue;
            else
                sequenceLengthValue=1;
            end

            if obj.IsRNN



                inC{inIdx}=stopConstPropagation(zeros([inputSizes{inIdx},sequenceLengthValue],'single'));
            else


                inC{inIdx}=stopConstPropagation(zeros(inputSizes{inIdx},'single'));
            end

            dataInSz{inIdx}=stopConstPropagation(zeros(1,4,'int32'));

        end

        layerObj=obj.CustomLayerProperties.layerObj{layerIdx};


        outC=cell(1,layerObj.NumOutputs);
        if coder.const(obj.CustomLayerProperties.hasDlarrayInputs(layerIdx))&&...
            coder.const(@feval,'dlcoderfeature','DLArrayInDAGCustomLayer')

            states=[];
            if coder.const(layerObj.isRowMajor())
                [outC{:}]=coder.internal.DeepLearningNetwork.layerPredictWithRowMajority(layerObj,...
                obj.CustomLayerProperties.isInputFormattedDlarray(layerIdx),inputFormats,...
                states,inC{:});
            else
                [outC{:}]=coder.internal.DeepLearningNetwork.layerPredictWithColMajority(layerObj,...
                obj.CustomLayerProperties.isInputFormattedDlarray(layerIdx),inputFormats,...
                states,inC{:});
            end
        else

            [outC{:}]=coder.internal.callPreservePrototype(@predict,layerObj,inC{:});

        end





        coder.ceval('-layout:any',obj.customPredictAnchor,coder.const(obj.CustomLayerProperties.layerIdx(layerIdx)),...
        coder.const(isFixedSizeInput),coder.const(layerObj.isRowMajor()),outC{:});

        iValidateOutputs(outC,layerObj.NumOutputs,obj.CustomLayerProperties.outputFormats{layerIdx},class(layerObj));

        if false



            if~isFixedSizeInput
                outSz=cell(1,layerObj.NumOutputs);
                [outSz{:}]=layerObj.propagateSize(dataInSz{:});

                coder.ceval(obj.customPropSzAnchor,coder.const(obj.CustomLayerProperties.layerIdx(layerIdx)),outSz{:});
            end
        end

    end
end

function x=stopConstPropagation(x)


    coder.inline('always');
    coder.ceval('(void)',coder.ref(x));
end

function iValidateOutputs(outC,numOutputs,outputFormats,customLayerClassName)
    for iOut=1:numOutputs


        if~coder.internal.isAmbiguousComplexity&&~coder.internal.isAmbiguousTypes
            coder.internal.assert(isa(outC{iOut},'single'),'dlcoder_spkg:cnncodegen:InvalidOutputDataType',iOut,...
            customLayerClassName,'IfNotConst','Fail');
        end


        outputDims=numel(outputFormats{iOut});
        if contains(outputFormats{iOut},'T')

            outputDims=outputDims-1;
        end
        coder.unroll();
        for iDim=1:outputDims
            coder.internal.assert(coder.internal.isConst(size(outC{iOut},iDim)),...
            'dlcoder_spkg:cnncodegen:VariableOutputSizeDimension',iDim,iOut,customLayerClassName,...
            'IfNotConst','Fail');
        end
    end
end
