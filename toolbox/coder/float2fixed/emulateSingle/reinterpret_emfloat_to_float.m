%#codegen

function op=reinterpret_emfloat_to_float(a)
    coder.allowpcode('plain');
    coder.inline('never');

    op=typecast(a,'single');

end
