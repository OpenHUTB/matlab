function scalingIsTrivial=isScalingTrivial(varOrType)





%#codegen
    coder.allowpcode('plain');
    coder.inline('always');

    nt=fixed.internal.type.extractNumericType(varOrType);

    scalingIsTrivial=...
    (0==nt.FixedExponent)&&...
    (1==nt.SlopeAdjustmentFactor)&&...
    (0==nt.Bias)&&...
    (~nt.isscalingunspecified);
end
