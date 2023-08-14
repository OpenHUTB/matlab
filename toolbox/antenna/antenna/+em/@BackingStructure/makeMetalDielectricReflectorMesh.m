function[Mesh,Parts]=makeMetalDielectricReflectorMesh(obj,isRemesh,numLayers)











    if~isinfGP(obj)
        if~isProbeFeedEnabled(obj)
            [Mesh,Parts]=makeFiniteGndMeshWithBalancedAntennaOnDielectric(...
            obj,isRemesh,numLayers);
        else
            [Mesh,Parts]=makeFiniteGndMeshWithUnbalancedAntennaOnDielectric(...
            obj,isRemesh,numLayers);
        end
    else
        if~isProbeFeedEnabled(obj)
            [Mesh,Parts]=makeInfiniteGndMeshWithBalancedAntennaOnDielectric(...
            obj,isRemesh,numLayers);
        else
            [Mesh,Parts]=makeInfiniteGndMeshWithUnBalancedAntennaOnDielectric(...
            obj,isRemesh,numLayers);
        end
    end