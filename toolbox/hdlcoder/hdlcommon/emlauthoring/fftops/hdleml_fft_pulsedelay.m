%#codegen
function enb_out=hdleml_fft_pulsedelay(enb_in,DelayNumber)






    coder.allowpcode('plain')
    eml_prefer_const(DelayNumber);

    fm=hdlfimath;
    nt_c=numerictype(0,ceil(log2(DelayNumber)),0);


    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);
    one_c=fi(1,nt_c,fm);
    zero_c=fi(0,nt_c,fm);

    persistent incount outcount
    if isempty(incount)
        incount=zero_c;
        outcount=zero_c;
    end


    persistent outenb
    if isempty(outenb)
        outenb=zero;
    end


    persistent incountlast outcountlast
    if isempty(incountlast)
        incountlast=zero;
        outcountlast=zero;
    end


    STEP_VALUE=one_c;
    COUNT_LIMIT=fi(DelayNumber-1,nt_c,fm);
    COUNT_MAX=fi(2^(nt_c.WordLength)-one_c,nt_c,fm);
    COMP_VALUE=fi(COUNT_MAX-COUNT_LIMIT+one_c,nt_c,fm);
    NEXT2LIMIT=fi(COUNT_LIMIT-one_c,nt_c,fm);

    persistent incount_step outcount_step
    if isempty(incount_step)
        incount_step=STEP_VALUE;
        outcount_step=STEP_VALUE;
    end


    enb_out=outenb;


    if outenb==zero&&incountlast==one
        outenb=one;
    elseif outenb==one&&outcountlast==one&&incountlast~=one
        outenb=zero;
    end


    outcount_t=outcount;
    if enb_out
        outcount(:)=outcount+outcount_step;
    else
        outcount(:)=zero_c;
    end


    incount_t=incount;
    if enb_in==one
        incount(:)=incount+incount_step;
    else
        incount(:)=zero_c;
    end


    if incount_t==DelayNumber-2
        incountlast=one;
    else
        incountlast=zero;
    end

    if outcount_t==DelayNumber-2
        outcountlast=one;
    else
        outcountlast=zero;
    end


    if incount_t==NEXT2LIMIT
        incount_step=COMP_VALUE;
    else
        incount_step=STEP_VALUE;
    end

    if outcount_t==NEXT2LIMIT
        outcount_step=COMP_VALUE;
    else
        outcount_step=STEP_VALUE;
    end





