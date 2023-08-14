%#codegen
function falling=xlate_util_zcfcn_detect_falling(inState,outState)



    coder.allowpcode('plain');

    ZERO_ZCSIG=uint8(0);
    POS_ZCSIG=uint8(1);
    NEG_ZCSIG=uint8(2);

    ZERO_RISING_EV_ZCSIG=uint8(100);

    falling=(((inState==POS_ZCSIG)&&((outState==ZERO_ZCSIG)||(outState==NEG_ZCSIG)))...
    ||((inState==ZERO_ZCSIG)&&(outState==NEG_ZCSIG)))||...
    ((inState==ZERO_RISING_EV_ZCSIG)&&(outState==NEG_ZCSIG));

end