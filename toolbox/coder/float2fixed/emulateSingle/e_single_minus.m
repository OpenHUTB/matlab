%#codegen

function c=e_single_minus(a,b)
    coder.allowpcode('plain');
    coder.inline('always');

    c=e_single_add(a,e_single_uminus(b));
end
