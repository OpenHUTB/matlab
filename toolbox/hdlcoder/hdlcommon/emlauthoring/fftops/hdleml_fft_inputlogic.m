%#codegen
function[enb_out,ready_out]=hdleml_fft_inputlogic(start,TotalPoint,TotalStage)





    coder.allowpcode('plain')
    eml_prefer_const(TotalPoint,TotalStage);


    nt_s=numerictype(0,TotalStage,0);
    fm=hdlfimath;


    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);
    one_s=fi(1,nt_s,fm);
    zero_s=fi(0,nt_s,fm);

    persistent scount
    if isempty(scount)
        scount=zero_s;
    end

    persistent sysenb ready
    if isempty(sysenb)
        sysenb=zero;
        ready=one;
    end

    persistent sclocklast nexttolast
    if isempty(sclocklast)
        sclocklast=zero;
        nexttolast=zero;
    end


    enb_out=sysenb;
    ready_out=ready;


    sclock=scount;
    if sysenb
        scount(:)=scount+one_s;
    end


    if sysenb==zero&&start==one
        sysenb=one;
    elseif sysenb==one&&start==zero&&sclocklast==one
        sysenb=zero;
    end


    if ready==one&&start==one
        ready=zero;
    elseif ready==zero&&nexttolast==one
        ready=one;
    end


    if sclock==TotalPoint-2
        sclocklast=one;
    else
        sclocklast=zero;
    end

    if sclock==TotalPoint-3
        nexttolast=one;
    else
        nexttolast=zero;
    end



