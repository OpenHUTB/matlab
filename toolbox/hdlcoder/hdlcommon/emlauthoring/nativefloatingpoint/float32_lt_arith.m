%#codegen
function b=float32_lt_arith(AS,AE,AM,BS,BE,BM)


    coder.allowpcode('plain')





    if(float32_is_nan(AE,AM)||float32_is_nan(BE,BM))
        b=false;
        return
    end


    if(AS~=BS)
        b=AS;
        return
    end


    if(AE~=BE)
        b=xor(AS,(AE<BE));
        return
    end


    b=xor(AS,uint8(AM<BM));
end
