%#codegen
function[waddr,raddr,enb_out]=hdleml_fft_bitrevaddr(enb,TotalPoint,TotalStage,BitRevDelay)





    coder.allowpcode('plain')
    eml_prefer_const(TotalPoint,TotalStage,BitRevDelay);

    fm=hdlfimath;

    nt_s=numerictype(0,TotalStage,0);


    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);
    one_s=fi(1,nt_s,fm);
    zero_s=fi(0,nt_s,fm);



    persistent wcount windex;
    if isempty(wcount)
        wcount=zero_s;
        windex=zero;
    end



    persistent rcount rindex;
    if isempty(rcount)
        rcount=zero_s;
        rindex=zero;
    end


    persistent rdenb
    if isempty(rdenb)
        rdenb=zero;
    end


    persistent wcountlast rcountlast wcountbitrev
    if isempty(wcountlast)
        wcountlast=zero;
        rcountlast=zero;
        wcountbitrev=zero;
    end


    enb_out=rdenb;


    if windex==one
        waddr=bitconcat(bitget(wcount,1:TotalStage));
    else
        waddr=wcount;
    end


    if rindex==one
        raddr=rcount;
    else
        raddr=bitconcat(bitget(rcount,1:TotalStage));
    end


    if rdenb==zero&&wcountbitrev==one
        rdenb=one;
    elseif rdenb==one&&rcountlast==one&&wcountbitrev==zero
        rdenb=zero;
    end


    if rcountlast==one
        rindex=bitcmp(rindex);
    end


    rcount_t=rcount;
    if enb_out
        rcount(:)=rcount+one_s;
    else
        rcount(:)=zero_s;
    end


    if wcountlast==one
        windex=bitcmp(windex);
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

    if wcount_t==BitRevDelay-2
        wcountbitrev=one;
    else
        wcountbitrev=zero;
    end

end





