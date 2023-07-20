function new_limits=panFromPixelToPixel2D(orig_limits,pixeldiff,range_pixel)

    delta=[pixeldiff./range_pixel,0];
    new_limits=matlab.graphics.interaction.internal.pan.calculatePannedLimits([orig_limits,0,0],-delta);
    new_limits=new_limits(1:4);