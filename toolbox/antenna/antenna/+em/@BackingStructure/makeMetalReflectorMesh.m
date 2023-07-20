function[Mesh,Parts]=makeMetalReflectorMesh(obj,isRemesh)











    if~isinfGP(obj)
        if~isProbeFeedEnabled(obj)
            [Mesh,Parts]=makeFiniteGndMeshWithBalancedAntennaOnFreeSpace(obj,isRemesh);
        else
            [Mesh,Parts]=makeFiniteGndMeshWithUnbalancedAntennaOnFreeSpace(obj,isRemesh);
        end
    else

        if~isProbeFeedEnabled(obj)
            [Mesh,Parts]=makeInfiniteGndMeshWithBalancedAntennaOnFreeSpace(obj,isRemesh);
        else
            [Mesh,Parts]=makeInfiniteGndMeshWithUnbalancedAntennaOnFreeSpace(obj,isRemesh);
        end
    end