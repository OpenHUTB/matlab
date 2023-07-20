function new_pt=TransformPoint(ds,pt)


    import matlab.graphics.internal.*

    [~,~,hDataSpace,belowMatrix]=getSpatialTransforms(ds);
    trans_pt=transformDataToWorld(hDataSpace,belowMatrix,pt(:));
    new_pt=transformWorldToNormalized(hDataSpace,belowMatrix,trans_pt);