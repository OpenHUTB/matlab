function out=getCompIgnoredFunctions



    out={'LibSFOutputFcnCall',...
    'LibSFOutputFcnCallInitialize',...
    'LibSFOutputFcnCallEnable',...
    'LibSFOutputFcnCallDisable',...
    'SLibCGIREmptyFcn',...
    'LibIsSampleHit',...
    'LibIsSpecialSampleHit',...
    'LibGetT',...
    'LibGetTaskTime',...
    'LibGetClockTick',...
    'SLibIsFirstInitCond',...
    'utAssert',...
    'rtIsNaN',...
    'rtIsInf',...
    'rtIsNaNF',...
    'rtIsInfF',...
    'SLibCGIRZeroOutDerivativesForSystemAndModelRef',...
    'SLibCGIRIteratorContainer',...
    'SLibCGIRGetIteratorName',...
    'SLibCGIRIsSampleHit',...
    'rangeQuery',...
    'rangeRelationship',...
    };





    out=[out,{...
    'abs',...
    'min',...
    'max',...
    'fix',...
    'mod',...
    'fmod',...
    'rem',...
    'round',...
    'sign',...
    'rem',...
    'ldexp'}];


    out=[out,{...
    'floor',...
    'floorf',...
    'ceil',...
    'ceilf',...
    'pow',...
    'powf'}];

    if slfeature('ExpandedEMLSupport')>0
        out=[out,{...
        'log',...
        'frexp',...
        'acos','acosf',...
        'asin','asinf',...
        'atan','atanf',...
        'cos','cosf',...
        'sin','sinf',...
        'tan','tanf',...
        'cosh','coshf',...
        'sinh','sinhf',...
        'tanh','tanhf',...
        'exp','expf',...
        'log','logf',...
        'log10','log10f',...
        'sqrt','sqrtf',...
        'fmod',...
        'atan2','atan2f',...
        'frexp','frexpf',...
        'rtGetNaN','rtGetNaNf',...
        'rtGetInf','rtGetInfF',...
        'rtGetMinusInf','rtGetMinusInfF',...
        'saturate',...
        'copysign',...
        'isFinite',...
        'hypot','hypotf'}];

    end
