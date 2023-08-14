%#codegen



function[Sign,Exponent,Mantissa]=extractComponentsFromUInt(cfType,x_uint)
    coder.allowpcode('plain');

    Sign=fi(bitget(x_uint,cfType.WordLength),0,1,0);
    Exponent=fi(bitsrl(bitsll(x_uint,1),cfType.MantissaLength+1),0,cfType.ExponentLength,0);
    Mantissa=fi(bitsrl(bitsll(x_uint,cfType.ExponentLength+1),cfType.ExponentLength+1),0,cfType.MantissaLength,0);
end
