%#codegen


function S=dts_load(mat)
    coder.inline('always');
    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    S_tmp=coder.load(mat);
    S=coder.const(dts_cast(S_tmp));
end
