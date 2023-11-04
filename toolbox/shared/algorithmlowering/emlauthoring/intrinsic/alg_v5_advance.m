function[state]=alg_v5_advance(state)

%#codegen

    coder.allowpcode('plain');

    icng=state(1);
    jsr=state(2);

    icng=eml_plus(eml_times(uint32(69069),icng,'uint32','wrap'),...
    uint32(1234567),'uint32','wrap');

    jsr=eml_bitxor(jsr,eml_lshift(jsr,uint8(13)));
    jsr=eml_bitxor(jsr,eml_rshift(jsr,uint8(17)));
    jsr=eml_bitxor(jsr,eml_lshift(jsr,uint8(5)));


    state(1)=icng;
    state(2)=jsr;

