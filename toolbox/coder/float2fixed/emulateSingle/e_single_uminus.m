%#codegen

function value=e_single_uminus(value)
    coder.allowpcode('plain');
    coder.inline('always');

    [sign,exp,mant]=e_single_unpack(value);
    value=bitset(value,32,~logical(sign));
end
