%#codegen
function[waddr,raddr,enb_out]=hdleml_fft_inputaddr(enb,TotalPoint,TotalStage)





    coder.allowpcode('plain')
    eml_prefer_const(TotalPoint,TotalStage);

    fm=hdlfimath;

    nt_s=numerictype(0,TotalStage,0);

    nt_i=numerictype(0,ceil(log2(TotalStage)),0);


    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);
    one_s=fi(1,nt_s,fm);
    zero_s=fi(0,nt_s,fm);
    one_i=fi(1,nt_i,fm);
    zero_i=fi(0,nt_i,fm);



    persistent wcount windex;
    if isempty(wcount)
        wcount=zero_s;
        windex=zero_i;
    end



    persistent rcount rindex;
    if isempty(rcount)
        rcount=zero_s;
        rindex=zero_i;
    end


    persistent rdenb
    if isempty(rdenb)
        rdenb=zero;
    end


    persistent wcountlast rcountlast wcounthalf
    if isempty(wcountlast)
        wcountlast=zero;
        rcountlast=zero;
        wcounthalf=zero;
    end


    STEP_VALUE=one_i;
    COUNT_LIMIT=fi(TotalStage-1,nt_i,fm);
    COUNT_MAX=fi(2^(nt_i.WordLength)-one_i,nt_i,fm);
    COMP_VALUE=fi(COUNT_MAX-COUNT_LIMIT+one_i,nt_i,fm);
    NEXT2LIMIT=fi(COUNT_LIMIT-one_i,nt_i,fm);

    persistent windex_step rindex_step
    if isempty(windex_step)
        windex_step=STEP_VALUE;
        rindex_step=STEP_VALUE;
    end


    enb_out=rdenb;


    waddr_rotate=fi(zeros(1,TotalStage),nt_s,fm);
    for ii=coder.unroll(1:TotalStage)
        waddr_rotate(ii)=bitrol(wcount,mod(TotalStage+1-ii,TotalStage));
    end
    waddr=hdleml_switch_multiport(2,1,windex,waddr_rotate);


    raddr_rotate=fi(zeros(1,TotalStage),nt_s,fm);
    for ii=coder.unroll(1:TotalStage)
        raddr_rotate(ii)=bitrol(rcount,mod(TotalStage-ii,TotalStage));
    end
    raddr=hdleml_switch_multiport(2,1,rindex,raddr_rotate);


    if rdenb==zero&&wcounthalf==one
        rdenb=one;
    elseif rdenb==one&&rcountlast==one&&wcounthalf==zero
        rdenb=zero;
    end


    rindex_t=rindex;
    if rcountlast==one
        rindex(:)=rindex+rindex_step;
    end


    rcount_t=rcount;
    if enb_out==one
        rcount(:)=rcount+one_s;
    else
        rcount(:)=zero_s;
    end


    windex_t=windex;
    if wcountlast==one
        windex(:)=windex+windex_step;
    end


    wcount_t=wcount;
    if enb==one
        wcount(:)=wcount+one_s;
    else
        wcount(:)=zero_s;
    end


    if wcount_t==TotalPoint-2
        wcountlast=one;
    else
        wcountlast=zero;
    end

    if rcount_t==TotalPoint-2
        rcountlast=one;
    else
        rcountlast=zero;
    end

    if wcount_t==TotalPoint/2-2
        wcounthalf=one;
    else
        wcounthalf=zero;
    end


    if windex_t==NEXT2LIMIT
        windex_step=COMP_VALUE;
    else
        windex_step=STEP_VALUE;
    end

    if rindex_t==NEXT2LIMIT
        rindex_step=COMP_VALUE;
    else
        rindex_step=STEP_VALUE;
    end


