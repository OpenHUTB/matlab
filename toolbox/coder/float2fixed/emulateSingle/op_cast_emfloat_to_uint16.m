%#codegen

function op=op_cast_emfloat_to_uint16(a)
    coder.allowpcode('plain');
    coder.inline('never');

    t=typecast(a,'single');
    op=cast(t,'uint16');

end
