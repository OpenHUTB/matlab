



%#codegen


function obj=setSizeDependentProperties(obj,inputFormats)
    coder.internal.prefer_const(inputFormats);



    coder.allowpcode('plain');



    networkInfo=coder.internal.getprop_if_defined(obj.NetworkInfo);
    if coder.const(isempty(networkInfo))


        inputSizes=coder.internal.getprop_if_defined(obj.CodegenInputSizes);
        coder.internal.assert(~isempty(inputSizes),'dlcoder_spkg:cnncodegen:DLCoderInternalError');


        tmpNetInfo=coder.const(feval('dltargets.internal.NetworkInfo',obj.DLTNetwork,...
        obj.CodegenInputSizes,coder.const(inputFormats)));
    else
        tmpNetInfo=networkInfo;
    end

    obj.NetworkInfo=tmpNetInfo;


    batchSize=obj.CodegenInputSizes{1}(4);


    obj.BatchSize=coder.const(batchSize);


    obj.setAnchor();

end
