%#codegen
function b=float32_eq(SA,EA,MA,SB,EB,MB)




    coder.allowpcode('plain')

    if(float32_is_nan(EA,MA)||float32_is_nan(EB,MB))
        b=false;
        return
    end


    b=(EA==EB)&&(MA==MB)&&((SA==SB)||((EA==0)&&(MA==0)));

end
