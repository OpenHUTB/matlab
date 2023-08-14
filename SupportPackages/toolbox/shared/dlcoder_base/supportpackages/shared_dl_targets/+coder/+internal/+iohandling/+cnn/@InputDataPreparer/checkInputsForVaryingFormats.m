%#codegen












function checkInputsForVaryingFormats(oldInputFormat,newInputFormat,callerFunction)

    coder.internal.prefer_const(oldInputFormat,newInputFormat,callerFunction);
    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.assert(coder.const(@isequal,oldInputFormat,newInputFormat),...
    'dlcoder_spkg:dlnetwork:VaryingInputFormat',...
    coder.const(newInputFormat),...
    coder.const(oldInputFormat),...
callerFunction...
    );

end