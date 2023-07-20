function res=isFiOrAnyNumericType(u)




%#codegen
    coder.allowpcode('plain');
    coder.inline('always')

    res=isfi(u)||fixed.internal.isAnyNumericType(u);
end
