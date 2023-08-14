%#codegen
function[outEvent,outState]=xlate_coder_falling_zcfcn(inState,inInput,...
    output_ex_Event,output_ex_State)







    coder.allowpcode('plain');


    ZERO_ZCSIG=cast(0,class(output_ex_State));
    POS_ZCSIG=cast(1,class(output_ex_State));
    NEG_ZCSIG=cast(2,class(output_ex_State));

    ZERO_FALLING_EV_ZCSIG=cast(101,class(output_ex_State));


    FALLING_ZCEVENT=cast(-1,class(output_ex_Event));
    NO_ZCEVENT=cast(0,class(output_ex_Event));

    if inInput>0
        outState=POS_ZCSIG;
    elseif inInput<0
        outState=NEG_ZCSIG;
    else
        outState=ZERO_ZCSIG;
    end

    if xlate_util_zcfcn_detect_falling(inState,outState)
        outEvent=FALLING_ZCEVENT;
    else
        outEvent=NO_ZCEVENT;
    end

    if((inState==POS_ZCSIG)&&(outState==ZERO_ZCSIG))
        outState=ZERO_FALLING_EV_ZCSIG;
    end
end