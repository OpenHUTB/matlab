%#codegen

function op=op_cast_emfloat_to_int16(a)
    coder.allowpcode('plain');
    coder.inline('never');

    t=typecast(a,'single');
    op=cast(t,'int16');

end
