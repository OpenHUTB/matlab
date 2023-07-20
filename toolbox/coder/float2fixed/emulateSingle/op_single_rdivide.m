%#codegen

function c=op_single_rdivide(a,b)
    coder.allowpcode('plain');
    coder.inline('always');

    c=rdivide(a,b);
end
