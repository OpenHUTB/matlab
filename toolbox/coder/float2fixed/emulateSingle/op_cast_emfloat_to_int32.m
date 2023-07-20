%#codegen

function op=op_cast_emfloat_to_int32(a)
    coder.allowpcode('plain');
    coder.inline('never');

    t=typecast(a,'single');
    op=cast(t,'int32');

end
