%#codegen

function op=op_cast_emfloat_to_uint8(a)
    coder.allowpcode('plain');
    coder.inline('never');

    t=typecast(a,'single');
    op=cast(t,'uint8');

end
