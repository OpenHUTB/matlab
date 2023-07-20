%#codegen
function b=float32_ne(AS,AE,AM,BS,BE,BM)


    coder.allowpcode('plain')

    b=~float32_eq(AS,AE,AM,BS,BE,BM);
end
