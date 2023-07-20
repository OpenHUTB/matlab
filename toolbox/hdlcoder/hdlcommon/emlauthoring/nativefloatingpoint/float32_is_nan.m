%#codegen
function b=float32_is_nan(E,M)


    coder.allowpcode('plain')

    b=((E==255)&&(M~=0));
end
