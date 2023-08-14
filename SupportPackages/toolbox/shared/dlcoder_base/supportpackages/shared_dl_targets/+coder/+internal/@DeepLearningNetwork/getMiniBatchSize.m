function minibatchsize=getMiniBatchSize(obj)
%#codegen



    coder.allowpcode('plain');

    inputSizes=coder.internal.getprop_if_defined(obj.CodegenInputSizes);
    coder.internal.assert(~isempty(inputSizes),'dlcoder_spkg:cnncodegen:DLCoderInternalError');
    minibatchsize=coder.const(inputSizes{1}(4));

end
