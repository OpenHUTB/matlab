
%#codegen

function[o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22]=emulateSingleEntryPoint(a,b)
    coder.allowpcode('plain');
    o1=op_single_times_scalars(a,b);
    o2=op_single_plus_scalars(a,b);
    o3=op_single_minus_scalars(a,b);
    o4=op_single_uminus_scalar(a);

    o5=op_single_ge(uint32(a),uint32(b));
    o6=op_single_gt(uint32(a),uint32(b));
    o7=op_single_le(uint32(a),uint32(b));
    o8=op_single_lt(uint32(a),uint32(b));

    o9=op_cast_int32_to_emfloat(int32(o1));
    o10=op_cast_int16_to_emfloat(int16(o1));
    o11=op_cast_int8_to_emfloat(int8(o1));

    o12=op_cast_uint32_to_emfloat(uint32(o1));
    o13=op_cast_uint16_to_emfloat(uint16(o1));
    o14=op_cast_uint8_to_emfloat(uint8(o1));

    o15=op_cast_emfloat_to_int32(uint32(o1));
    o16=op_cast_emfloat_to_int16(uint32(o1));
    o17=op_cast_emfloat_to_int8(uint32(o1));

    o18=op_cast_emfloat_to_uint32(uint32(o1));
    o19=op_cast_emfloat_to_uint16(uint32(o1));
    o20=op_cast_emfloat_to_uint8(uint32(o1));

    o21=reinterpret_float_to_emfloat(a);
    o22=reinterpret_emfloat_to_float(uint32(a));

end

function c=op_single_times_scalars(a,b)
    coder.inline('never');
    c=op_single_times(a,b);
end

function c=op_single_plus_scalars(a,b)
    coder.inline('never');
    c=op_single_plus(a,b);
end

function c=op_single_minus_scalars(a,b)
    coder.inline('never');
    c=op_single_minus(a,b);
end

function c=op_single_uminus_scalar(a)
    coder.inline('never');
    c=op_single_uminus(a);
end
