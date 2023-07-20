%#codegen
function[cur_indx,pre_indx,Index_clkenb,Index]...
    =hdleml_cascade_index(cnt,last_indx,cmp_sel_addr,tmp_idx,stage_vld,compare_true,nxt_indx,...
    decomposeStage,isStartStage)


    coder.allowpcode('plain')
    eml_prefer_const(decomposeStage,isStartStage);

    ntc=numerictype(cnt);
    nti=numerictype(tmp_idx);
    fm=hdlfimath;

    zero=fi(0,0,1,0,fm);
    one=fi(1,0,1,0,fm);
    one_c=fi(1,ntc,fm);


    cnt_idx=fi(cnt,nti,fm);
    cntAddOne=fi(cnt+one_c,nti,fm);


    cur_indx=cntAddOne;


    if cmp_sel_addr==one
        pre_indx=cnt_idx;
    else
        pre_indx=tmp_idx;
    end


    idxclken_tmp=bitand(stage_vld,cmp_sel_addr);
    not_compare_true=bitcmp(compare_true);
    update_clken=bitand(stage_vld,not_compare_true);
    Index_clkenb=bitor(idxclken_tmp,update_clken);


    end_cnt=fi(decomposeStage-1,ntc,fm);
    cnt_dec2=fi(end_cnt-one_c,ntc,fm);
    if cnt==cnt_dec2
        outvld_tmp=one;
    else
        outvld_tmp=zero;
    end



    if isStartStage
        Index=nxt_indx;
    else
        add_indx=fi(last_indx+end_cnt,nti,fm);

        if outvld_tmp==one
            Index=add_indx;
        else
            Index=nxt_indx;
        end
    end
