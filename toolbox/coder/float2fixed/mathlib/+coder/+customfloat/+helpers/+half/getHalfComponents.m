%#codegen






function[Sign,Exponent,Mantissa]=getHalfComponents(bitPattern)

    coder.allowpcode('plain');





    HALF_SIGN_MASK=uint16(32768);
    HALF_EXPONENT_MASK=uint16(31744);
    HALF_MANTISSA_MASK=uint16(1023);

    Sign=bitand(bitPattern,HALF_SIGN_MASK);
    Exponent=bitand(bitPattern,HALF_EXPONENT_MASK);
    Mantissa=bitand(bitPattern,HALF_MANTISSA_MASK);
end