


%#codegen


function obj=setNetworkInfo(obj)




    coder.allowpcode('plain');



    networkInfo=coder.internal.getprop_if_defined(obj.NetworkInfo);
    if coder.const(isempty(networkInfo))


        inputSizes=coder.internal.getprop_if_defined(obj.CodegenInputSizes);
        coder.internal.assert(~isempty(inputSizes),'dlcoder_spkg:cnncodegen:DLCoderInternalError');

        tmpNetInfo=coder.const(feval('dltargets.internal.NetworkInfo',obj.DLTNetwork,...
        obj.CodegenInputSizes));

    else
        tmpNetInfo=networkInfo;
    end
    obj.NetworkInfo=tmpNetInfo;

end

