%#codegen
function rising=xlate_util_zcfcn_detect_rising(inState,outState)



    coder.allowpcode('plain');

    ZERO_ZCSIG=uint8(0);
    POS_ZCSIG=uint8(1);
    NEG_ZCSIG=uint8(2);

    ZERO_FALLING_EV_ZCSIG=uint8(101);

    rising=(((inState==NEG_ZCSIG)&&((outState==ZERO_ZCSIG)||(outState==POS_ZCSIG)))||...
    ((inState==ZERO_ZCSIG)&&(outState==POS_ZCSIG)))||...
    ((inState==ZERO_FALLING_EV_ZCSIG)&&(outState==POS_ZCSIG));
end