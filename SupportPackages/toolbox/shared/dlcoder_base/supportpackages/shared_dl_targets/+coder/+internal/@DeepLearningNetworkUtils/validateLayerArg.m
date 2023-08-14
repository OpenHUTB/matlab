%#codegen

function layerArg=validateLayerArg(layerArg)



    coder.allowpcode('plain');


    coder.internal.assert(coder.internal.isConst(layerArg),...
    'dlcoder_spkg:cnncodegen:nonconst_layerArg');


    layerArg=convertStringsToChars(layerArg);

    if coder.const(ischar(layerArg))
        coder.internal.assert(coder.const(~isempty(layerArg)),...
        'dlcoder_spkg:cnncodegen:invalid_layerIdx',...
        layerArg);
    else
        coder.internal.assert((coder.const(isscalar(layerArg))&&coder.const(layerArg>0)),...
        'dlcoder_spkg:cnncodegen:invalid_layerIdx',...
        layerArg);
    end
end

