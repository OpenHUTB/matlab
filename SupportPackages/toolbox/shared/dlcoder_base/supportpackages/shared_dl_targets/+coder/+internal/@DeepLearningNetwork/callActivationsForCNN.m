















%#codegen


function out=callActivationsForCNN(obj,inputsT,layerIdx,portIdx,outsize)

    coder.allowpcode('plain');
    coder.inline('always');
    coder.extrinsic('coder.internal.DeepLearningNetwork.prepareInputSizesForCeval');



    out_type='single';
    outsizeC=outsize;

    isImageInput=numel(outsize)==4;
    if isImageInput
        if coder.isColumnMajor


            outsizeC(1)=outsize(2);
            outsizeC(2)=outsize(1);
        else

            outsizeC(1)=outsize(4);
            outsizeC(2)=outsize(3);
            outsizeC(3)=outsize(1);
            outsizeC(4)=outsize(2);
        end
    else







        if coder.isRowMajor

            outsizeC(1)=outsize(2);
            outsizeC(2)=outsize(1);
        end
    end

    out=coder.nullcopy(zeros(outsizeC,out_type));

    coder.ceval('-layout:any',obj.activationAnchorName,obj.NetworkInfo,coder.const(obj.getMiniBatchSize));


    coder.ceval('-preservearraydims','-layout:any',obj.activationFcnName,...
    coder.wref(obj.anchor),...
    coder.const(layerIdx),...
    coder.const(portIdx-1),...
    coder.internal.valuelistfun(@coder.rref,inputsT,'gpu'),...
    coder.wref(out,'gpu'));

    obj.callPredictForCustomLayers(1);
end
