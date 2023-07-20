%#codegen

function c=op_single_mrdivide(a,b)
    coder.allowpcode('plain');
    coder.inline('always');

    c=rdivide(a,b);
end
