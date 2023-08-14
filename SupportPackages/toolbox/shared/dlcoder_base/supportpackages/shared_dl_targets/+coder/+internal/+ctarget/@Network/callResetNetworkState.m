%#codegen

function callResetNetworkState(obj,codegenInputSizes)




    coder.allowpcode('plain');
    coder.inline('always');





    coder.internal.assert(~isempty(obj.NetworkState),'dlcoder_spkg:cnncodegen:NoInferenceCalls');


    obj.initializeOrResetState(codegenInputSizes);

end
