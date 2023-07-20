%#codegen
function[cnt_clkenb,cntenb_tmp,invld_and_not_cntenb]...
    =hdleml_cascade_controller(in_vld,stage_vld,cnt_enb,cnt,decomposeStage)


    coder.allowpcode('plain')
    eml_prefer_const(decomposeStage);

    ntc=numerictype(cnt);
    fm=hdlfimath;

    zero=fi(0,0,1,0,fm);
    one=fi(1,0,1,0,fm);




    invld_or_cntenb=bitor(in_vld,cnt_enb);
    cnt_clkenb=bitand(stage_vld,invld_or_cntenb);

    if cnt<fi(decomposeStage-1,ntc,fm)
        cntenb_tmp=one;
    else
        cntenb_tmp=zero;
    end


    not_cnt_enb=bitcmp(cnt_enb);
    invld_and_not_cntenb=bitand(in_vld,not_cnt_enb);

