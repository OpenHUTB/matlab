




%#codegen
%#internal

function obj=setCustomLayerProperties(obj)




    coder.allowpcode('plain');

    coder.extrinsic('coder.internal.coderNetworkUtils.getCustomLayerProps');






    coder.internal.assert(~isempty(coder.internal.getprop_if_defined(obj.NetworkInfo)),'dlcoder_spkg:cnncodegen:DLCoderInternalError');

    customLayerProps=coder.internal.getprop_if_defined(obj.CustomLayerProperties);
    if coder.const(isempty(customLayerProps))

        tmpCustomLayerProps=coder.const(@coder.internal.coderNetworkUtils.getCustomLayerProps,obj.NetworkInfo);



        coder.internal.errorIf(coder.internal.isMxArray(tmpCustomLayerProps),"dlcoder_spkg:cnncodegen:CustomLayerMxArrayError");

    else
        tmpCustomLayerProps=customLayerProps;
    end

    obj.CustomLayerProperties=tmpCustomLayerProps;

end

