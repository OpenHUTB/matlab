%#codegen

function op=reinterpret_float_to_emfloat(a)
    coder.allowpcode('plain');
    coder.inline('never');

    op=typecast(a,'uint32');

end
