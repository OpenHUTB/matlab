%#codegen

function isActivationLayerFused=hasFusedActivationLayers(obj,activationLayerIndices)





    coder.allowpcode('plain');

    isActivationLayerFused=false;

    for iActivation=1:numel(activationLayerIndices)

        isLayerFused=obj.IsFusedLayerMap(activationLayerIndices(iActivation));
        if isLayerFused
            isActivationLayerFused=true;
            break
        end
    end

end