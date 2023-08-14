%#codegen


function out=permuteData(in,permuteVec)
    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.allowHalfInputs;
    out=permute(in,permuteVec);
end
