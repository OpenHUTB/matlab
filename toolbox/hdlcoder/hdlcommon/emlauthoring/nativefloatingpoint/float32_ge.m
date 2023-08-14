%#codegen
function b=float32_ge(AS,AE,AM,BS,BE,BM)




    coder.allowpcode('plain')

    if(float32_is_nan(AE,AM)||float32_is_nan(BE,BM))
        b=false;
        return
    end


    b=float32_eq(AS,AE,AM,BS,BE,BM)||float32_lt_arith(BS,BE,BM,AS,AE,AM);

