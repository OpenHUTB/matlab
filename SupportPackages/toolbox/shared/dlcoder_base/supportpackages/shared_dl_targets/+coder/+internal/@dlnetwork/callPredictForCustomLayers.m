%#codegen


function callPredictForCustomLayers(obj)






    coder.inline('never');
    coder.allowpcode('plain');


    coder.ceval(obj.callPredictForCustomLayersAnchor,coder.wref(obj.anchor));

    isFixedSizeInput=true;


    for layerIdx=coder.unroll(1:obj.CustomLayerProperties.numCustomLayers)

        inputSizes=obj.CustomLayerProperties.inputSizes{layerIdx};

        numInputs=numel(inputSizes);
        inC=cell(1,numInputs);

        for inIdx=1:numInputs



            inC{inIdx}=stopConstPropagation(zeros(inputSizes{inIdx},'single'));
        end

        layerObj=obj.CustomLayerProperties.layerObj{layerIdx};

        outC=cell(1,layerObj.NumOutputs);


        if coder.const(layerObj.isRowMajor())
            [outC{:}]=coder.internal.dlnetwork.layerPredictWithRowMajority(layerObj,...
            obj.CustomLayerProperties.isInputFormattedDlarray(layerIdx),...
            obj.CustomLayerProperties.inputFormats{layerIdx},inC{:});
        else
            [outC{:}]=coder.internal.dlnetwork.layerPredictWithColMajority(layerObj,...
            obj.CustomLayerProperties.isInputFormattedDlarray(layerIdx),...
            obj.CustomLayerProperties.inputFormats{layerIdx},inC{:});
        end






        coder.ceval('-layout:any',obj.customPredictAnchor,coder.const(obj.CustomLayerProperties.layerIdx(layerIdx)),...
        coder.const(isFixedSizeInput),coder.const(layerObj.isRowMajor()),outC{:});

        iValidateOutputs(outC,layerObj.NumOutputs,obj.CustomLayerProperties.outputFormats{layerIdx},class(layerObj));

    end
end

function x=stopConstPropagation(x)


    coder.inline('always');
    coder.ceval('(void)',coder.ref(x));
end

function iValidateOutputs(outC,numOutputs,outputFormats,customLayerClassName)
    for iOut=1:numOutputs




        if~(coder.internal.isAmbiguousTypes()||coder.internal.isAmbiguousComplexity())

            coder.internal.assert(isa(outC{iOut},'single'),'dlcoder_spkg:cnncodegen:InvalidDlarrayOutputDataType',iOut,...
            customLayerClassName,'IfNotConst','Fail');

        end


        coder.unroll();
        for iDim=1:numel(outputFormats{iOut})
            coder.internal.assert(coder.internal.isConst(size(outC{iOut},iDim)),...
            'dlcoder_spkg:cnncodegen:VariableOutputSizeDimension',iDim,iOut,customLayerClassName,'IfNotConst','Fail');
        end
    end
end
