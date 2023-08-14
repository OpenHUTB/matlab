function[xlt,ylt,zlt]=TransformLimits(ds,xl,yl,zl)


    import matlab.graphics.internal.*




    try
        mat=makehgtform;
        world_limits_bottom=transformDataToWorld(ds,mat,[xl(1);yl(1);zl(1)]);
        world_limits_top=transformDataToWorld(ds,mat,[xl(2);yl(2);zl(2)]);
    catch
        xlt=nan(2,1);
        ylt=nan(2,1);
        zlt=nan(2,1);
        return
    end

    norm_limits_bottom=transformWorldToNormalized(ds,mat,world_limits_bottom);
    norm_limits_top=transformWorldToNormalized(ds,mat,world_limits_top);

    xlt=sort([norm_limits_bottom(1),norm_limits_top(1)]);
    ylt=sort([norm_limits_bottom(2),norm_limits_top(2)]);
    zlt=sort([norm_limits_bottom(3),norm_limits_top(3)]);