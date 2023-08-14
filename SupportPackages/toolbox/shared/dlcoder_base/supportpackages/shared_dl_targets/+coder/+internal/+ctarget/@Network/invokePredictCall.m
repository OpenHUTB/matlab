function Z=invokePredictCall(obj,layer,X,states,numOutputElems)




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    [hasDlarrayInputs,inputFormats,outputFormats]=coder.const(@feval,...
    'getDlarrayProperties',obj.DLCustomCoderNetwork,layer.Name);
    hasFormattedDlarrayInputs=coder.const(isa(layer,'nnet.layer.Formattable'));

    Z=cell(1,numOutputElems);
    isDLNetwork=coder.const(isa(obj,'coder.internal.ctarget.dlnetwork'));


    isDagNetworkAndDLArrayInDAGCustomLayerOn=~isDLNetwork&&coder.const(@feval,'dlcoderfeature',...
    'DLArrayInDAGCustomLayer');





    propagateDlArray=~isa(layer,'coder.internal.layer.NumericDataLayer')&&...
    (hasDlarrayInputs&&(isDLNetwork||isDagNetworkAndDLArrayInDAGCustomLayerOn));

    if propagateDlArray

        obj.validateFixedSizeSequenceLength(layer,X);
        shouldPreserveFunctionInterface=false;
        [Z{:}]=coder.internal.coderNetworkUtils.customLayerPredict(layer,...
        hasFormattedDlarrayInputs,inputFormats,states,shouldPreserveFunctionInterface,X{:});
    else

        if coder.const(isempty(states))
            [Z{:}]=predict(layer,X{:});
        else
            [Z{:}]=predict(layer,X{:},states{:});
        end
    end

    coder.internal.ctarget.Network.validateOutputAfterPredict(X,Z,inputFormats,outputFormats,layer);

end