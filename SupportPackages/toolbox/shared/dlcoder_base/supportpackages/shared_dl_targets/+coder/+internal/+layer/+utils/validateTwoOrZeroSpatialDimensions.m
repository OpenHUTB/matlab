function validateTwoOrZeroSpatialDimensions(fmt)




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(fmt)

    isNumSpatialDimsSupported=coder.const(coder.internal.layer.utils.numSpatialDims(fmt)==2)||...
    coder.const(coder.internal.layer.utils.numSpatialDims(fmt)==0);

    assert(coder.const(isNumSpatialDimsSupported),...
    'Expected format to have only two or zero spatial dimensions ''S''')
end

